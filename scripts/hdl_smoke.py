"""Toolchain diagnostic only: Amaranth -> Verilog -> Yosys and Icarus.

This binary XOR fixture is not a model of the signal-strength CORDIC circuit.
"""
from pathlib import Path
import subprocess
from amaranth import Elaboratable, Module, Signal
from amaranth.back import verilog


class XorFixture(Elaboratable):
    def __init__(self):
        self.a = Signal(name="a")
        self.b = Signal(name="b")
        self.q = Signal(name="q")

    def elaborate(self, platform):
        m = Module()
        m.d.comb += self.q.eq(self.a ^ self.b)
        return m


def main():
    out = Path("build/hdl")
    out.mkdir(parents=True, exist_ok=True)
    design = XorFixture()
    source = out / "xor.v"
    source.write_text(verilog.convert(design, name="xor_fixture", ports=[design.a, design.b, design.q]))
    test = out / "test.v"
    test.write_text('''module test;
reg a,b; wire q;
xor_fixture dut(.a(a),.b(b),.q(q));
initial begin
  a=0;b=0;#1;if(q!==0)$fatal(1,"00");
  a=0;b=1;#1;if(q!==1)$fatal(1,"01");
  a=1;b=0;#1;if(q!==1)$fatal(1,"10");
  a=1;b=1;#1;if(q!==0)$fatal(1,"11");
  $display("PASS: four XOR vectors");$finish;
end
endmodule
''')
    subprocess.run(["yosys", "-Q", "-T", "-p", f"read_verilog {source}; synth -top xor_fixture; write_json {out / 'synth.json'}"], check=True, stdout=subprocess.DEVNULL)
    subprocess.run(["iverilog", "-o", str(out / "simulation"), str(source), str(test)], check=True)
    subprocess.run(["vvp", str(out / "simulation")], check=True)


if __name__ == "__main__":
    main()
