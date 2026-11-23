#include <algorithm>
#include <array>
#include <cassert>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <utility>
using I = long long;
constexpr I max_angle = 9000000000000LL;
constexpr double unit = 1e-12;
constexpr double angle_rad = 0.017453292519943295769 * 1e-11;
constexpr double guard = 1e-14;
constexpr double outer = 0.502;
constexpr double inner = 0.49;
constexpr std::array<I, 12> powers{1,10,100,1000,10000,100000,1000000,10000000,100000000,1000000000,10000000000LL,100000000000LL};
constexpr std::array<I,4> coefficients{4,2,2,1};

struct Point { I x, y; };
struct Hit { double error = 0; double ticks = 0; I value = 0; I lo = 0; I hi = 0; };
struct Audit {
    bool latest;
    I initial;
    std::array<I,25> step{};
    std::array<I,5> fine{};
    I limit;
    double upper_x = 0, upper_y = 0;
    I coarse_count = 0, fine_count = 0, terminal_count = 0, pruned_count = 0;
    Hit max_x, max_y;
    explicit Audit(bool is_latest) : latest(is_latest) {
        double gain = 1.0;
        double smallest_half_margin = 1.0;
        for (int n=0; n<25; ++n) {
            const int digit = n ? (n-1)/4+1 : 0;
            const I coefficient = n ? coefficients[(n-1)%4] : 1;
            const double q = static_cast<double>(coefficient) / powers[std::min(4, digit)];
            const double radians = std::atan(q) / powers[std::max(0, digit-4)];
            const double degrees = radians / 0.017453292519943295769;
            const double scaled = degrees * 1e12 / 10.0;
            step[n] = std::llround(scaled);
            smallest_half_margin = std::min(smallest_half_margin, 0.5-std::abs(scaled-step[n]));
            gain *= std::cos(radians);
        }
        initial = std::llround(gain*1e12);
        smallest_half_margin = std::min(smallest_half_margin,0.5-std::abs(gain*1e12-initial));
        fine[0] = step.back()/10;
        for (int i=1; i<5; ++i) fine[i] = fine[i-1]/10;
        limit = max_angle/2;
        for (int i=1; i<25; ++i) limit=std::max(step[i],limit-step[i]);
        for (I a: fine) for (int i=0;i<9;++i) limit=std::max(a,limit-a);
        std::printf("params initial=%lld margin=%.9g final_angle_residual_units<=%lld fine=",initial,smallest_half_margin,limit);
        for (I a: fine) std::printf(" %lld",a);
        std::printf("\ncoarse");
        for (I a: step) std::printf(" %lld",a);
        std::puts("");
    }
    static Point rotate(Point p, I divisor, I signed_coefficient) {
        return {p.x-signed_coefficient*(p.y/divisor), p.y+signed_coefficient*(p.x/divisor)};
    }
    Point evaluate(I angle) const {
        Point p{initial,initial};
        I center = step[0];
        Point shift{};
        for (int i=1;i<25;++i) {
            int digit = (i-1)/4+1;
            I div = powers[digit], sign = angle >= center ? 1 : -1;
            if (i==24 && latest) shift={p.x/powers[7],p.y/powers[7]};
            p=rotate(p,div,sign*coefficients[(i-1)%4]);
            center+=sign*step[i];
        }
        if (!latest) shift={p.x/powers[7],p.y/powers[7]};
        for (I a: fine) {
            for (int i=0;i<9;++i) {
                I sign = angle >= center ? 1 : -1;
                center += sign*a;
                p={p.x-sign*shift.y,p.y+sign*shift.x};
            }
            shift={shift.x/10,shift.y/10};
        }
        return p;
    }
    void record(double ticks, Point p, I lo, I hi) {
        double r=ticks*angle_rad;
        double ex=std::abs(p.x*unit-std::cos(r)), ey=std::abs(p.y*unit-std::sin(r));
        if (ex>max_x.error) max_x={ex,ticks,p.x,lo,hi};
        if (ey>max_y.error) max_y={ey,ticks,p.y,lo,hi};
    }
    void terminal(I lo,I hi,I center,Point p) {
        ++terminal_count;
        assert(std::max(std::llabs(lo-center),std::llabs(hi-center)) <= limit);
        record(std::max(0.0,lo-inner),p,lo,hi);
        record(std::min(static_cast<double>(max_angle),hi+inner),p,lo,hi);
        double lower = std::max(0.0,lo-outer)*angle_rad;
        double higher = std::min(static_cast<double>(max_angle),hi+outer)*angle_rad;
        upper_x=std::max(upper_x,std::max(std::abs(p.x*unit-std::cos(lower)),std::abs(p.x*unit-std::cos(higher)))+guard);
        upper_y=std::max(upper_y,std::max(std::abs(p.y*unit-std::sin(lower)),std::abs(p.y*unit-std::sin(higher)))+guard);
    }
    void refine(I lo,I hi,I center,Point p,const std::array<Point,5>& shifts,int digit) {
        ++fine_count;
        if (digit==5) { terminal(lo,hi,center,p); return; }
        const double dir=center*angle_rad, c=std::cos(dir), s=std::sin(dir);
        const double d=(std::max(std::llabs(lo-center),std::llabs(hi-center))+outer)*angle_rad;
        const double tail=(limit+outer)*angle_rad;
        double bx=std::abs(p.x*unit-c)+std::abs(s)*tail+0.5*d*d+guard;
        double by=std::abs(p.y*unit-s)+std::abs(c)*tail+0.5*d*d+guard;
        for (int i=digit;i<5;++i) {
            bx += 9.0*std::abs(s*(fine[i]*angle_rad)-shifts[i].y*unit);
            by += 9.0*std::abs(c*(fine[i]*angle_rad)-shifts[i].x*unit);
        }
        if (bx<=max_x.error-guard && by<=max_y.error-guard) {
            ++pruned_count;
            upper_x=std::max(upper_x,bx);
            upper_y=std::max(upper_y,by);
            return;
        }
        I a=fine[digit];
        for (int k=-9;k<=9;k+=2) {
            I left=k==-9 ? lo : std::max(lo,center+(k-1)*a);
            I right=k==9 ? hi : std::min(hi,center+(k+1)*a-1);
            if (left<=right) {
                Point out{p.x-k*shifts[digit].y,p.y+k*shifts[digit].x};
                refine(left,right,center+k*a,out,shifts,digit+1);
            }
        }
    }
    void split(I lo,I hi,I center,Point p,int i,Point prior={}) {
        if (i==25) {
            ++coarse_count;
            std::array<Point,5> shifts{};
            Point base=latest ? prior : p;
            for (int k=0;k<5;++k) shifts[k]={base.x/powers[7+k],base.y/powers[7+k]};
            refine(lo,hi,center,p,shifts,0);
            return;
        }
        const I divisor=powers[(i-1)/4+1], c=coefficients[(i-1)%4];
        if (lo<center) split(lo,std::min(hi,center-1),center-step[i],rotate(p,divisor,-c),i+1,p);
        if (hi>=center) split(std::max(lo,center),hi,center+step[i],rotate(p,divisor,c),i+1,p);
    }
    void run() {
        std::printf("model=%s\n",latest ? "cordic_latest" : "cordic_error");
        if (latest) {
            for (double deg: {0.,12.3,45.,70.,90.}) {
                Point p=evaluate(std::llround(deg*1e11));
                std::printf("matlab_reference %.1f sin %.12f cos %.12f\n",deg,p.y*unit,p.x*unit);
            }
        }
        for (I n=0; n<=500000; ++n) {
            I ticks=max_angle*n/500000;
            record(ticks,evaluate(ticks),ticks,ticks);
        }
        split(0,max_angle,step[0],{initial,initial},1);
        std::printf("counts coarse=%lld fine=%lld terminal=%lld pruned=%lld\n",coarse_count,fine_count,terminal_count,pruned_count);
        auto result=[&](const char* label, const Hit& h, double upper) {
            I ticks=std::llround(h.ticks);
            Point v=evaluate(ticks);
            assert((label[0]=='s'?v.y:v.x)==h.value);
            std::printf("%s witness=%.15g upper=%.15g theta_deg=%.15f input_tick=%lld interval=[%lld,%lld] raw_output=%lld\n",
                label,h.error,upper,h.ticks/1e11,ticks,h.lo,h.hi,h.value);
        };
        result("sin",max_y,upper_y);
        result("cos",max_x,upper_x);
    }
};
int main() {
    std::setvbuf(stdout,nullptr,_IONBF,0);
    Audit(true).run();
    Audit(false).run();
    return 0;
}
