from decimal import Decimal as D, ROUND_HALF_UP, getcontext
import math
import random
import re
from pathlib import Path

getcontext().prec = 70
pi = D("3.141592653589793238462643383279502884197169399375105820974944592307816406")
scale = 10**12
angle_scale = 10**11
coef = (4, 2, 2, 1)

def atan(x):
    if x == 1:
        return pi / 4
    result = power = x
    for n in range(1, 200):
        power *= -x*x
        term = power/(2*n+1)
        result += term
        if abs(term) < D("1e-65"):
            return result
    raise ArithmeticError("atan series did not converge")

def trig(x, sine):
    power = x if sine else D(1)
    result = power
    for n in range(1, 90):
        power *= -x*x/((2*n)*(2*n+1 if sine else 2*n-1))
        result += power
        if abs(power) < D("1e-65"):
            return result
    raise ArithmeticError("trig series did not converge")

def nearest(x):
    return int(x.to_integral_value(rounding=ROUND_HALF_UP))

def shift(x, n):
    return int(math.copysign(1, x))*(abs(x)//(10**n))

radians = [pi/4] + [atan(D(c)/10**min(d,4))/10**max(d-4,0) for d in range(1,7) for c in coef]
angle_real = [r*180/pi*angle_scale for r in radians]
coarse = [nearest(t) for t in angle_real]
gain = D(1)
for r in radians:
    gain *= trig(r, False)
start = nearest(gain*scale)
fine = [coarse[-1]//10**n for n in range(1,6)]
report = Path(__file__).with_name("result.txt").read_text()
assert coarse == [int(n) for n in re.search(r"^coarse (.*)$",report,re.M)[1].split()]
assert start == int(re.search(r"initial=(\d+)",report)[1])
print("High-precision constants match C++:",len(coarse),"angles plus initial gain")
print("Minimum half-rounding margin:", min(D("0.5")-abs(raw-fixed) for raw,fixed in zip(angle_real+[gain*scale],coarse+[start])))

def direct(tick, latest):
    residual = tick - coarse[0]
    x = y = start
    for i, step in enumerate(coarse[1:]):
        power, coefficient = i//4+1, coef[i%4]
        sign = 1 if residual >= 0 else -1
        residual -= sign*step
        old = x,y
        x,y = x-sign*coefficient*shift(y,power), y+sign*coefficient*shift(x,power)
    held_x,held_y = old if latest else (x,y)
    for power, step in enumerate(fine, 7):
        dx,dy = shift(held_x,power), shift(held_y,power)
        for k in range(9):
            sign = 1 if residual >= 0 else -1
            residual -= sign*step
            x,y = x-sign*dy,y+sign*dx
    return x,y

def actual_group(r, a):
    k = 0
    for j in range(9):
        sign = 1 if r >= 0 else -1
        r -= sign*a
        k += sign
    return k

seed = random.Random(20261123)
for a in fine:
    edges = [k*a+offset for k in range(-12,13) for offset in (-1,0,1)]
    for r in edges+[seed.randint(-100*a,100*a) for m in range(500)]:
        expected = min(9,max(-9,2*(r//(2*a))+1))
        assert actual_group(r,a)==expected
print("Nine-step interval boundaries match individual sign updates")

for row in re.findall(r"^matlab_reference (\S+) sin (\S+) cos (\S+)$",report,re.M):
    degrees, sin_ref, cos_ref = map(D,row)
    observed = direct(nearest(degrees*angle_scale),True)
    assert observed == (nearest(cos_ref*scale),nearest(sin_ref*scale))
print("Five prior MATLAB results agree to the fixed-point unit")

for is_latest, section in zip((True,False),report.split("model=")[1:]):
    for kind, angle, tick, stored in re.findall(r"^(sin|cos) .* theta_deg=(\S+) input_tick=(\d+) .* raw_output=(-?\d+)$",section,re.M):
        value = direct(int(tick),is_latest)[kind=="sin"]
        assert value==int(stored)
        assert nearest(D(angle)*angle_scale)==int(tick)
        assert nearest(D(float(angle)*1e12/10))==int(tick)
        ref = trig(D(angle)*pi/180,kind=="sin")
        print(section.splitlines()[0], kind, "angle", angle, "model", D(value)/scale,
              "reference", f"{ref:.17f}", "abs error", f"{abs(D(value)/scale-ref):.10e}")

weights = (1,)+(4,2,2,1)*6+(9,)*5
print("Uniform model support half-width", D(sum(weights))/scale,
      "standard deviation", (D(sum(w*w for w in weights))/3).sqrt()/scale)
