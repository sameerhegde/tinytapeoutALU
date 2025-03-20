import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cpu(dut):
    dut._log.info("Start CPU Test")

    # Start the clock with 10 us period (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset CPU")
    dut.rst_n.value = 0
    dut.uio_in.value = 0  # Write enable low initially
    dut.ui_in.value = 0   # No instruction initially
    await ClockCycles(dut.clk, 10)  # Wait 10 cycles during reset
    #dut.rst_n.value = 1  # Deassert reset

    # Enable write (pmWrEn)
    dut.uio_in.value = 0b10000000  # uio_in[7] = 1 (Write Enable)

    # Load instructions into program memory
    instructions = [
        (0b000_0000, 0b1_0010011), (0b000_0001, 0b0_000_0000),
        (0b000_0010, 0b00000_0011), (0b000_0011, 0b0000000_0),

        (0b000_0100, 0b1_0010011), (0b000_0101, 0b0_000_0000),
        (0b000_0110, 0b00000_0010), (0b000_0111, 0b0000000_0),

        (0b000_1000, 0b0), (0b000_1001, 0b0),
        (0b000_1010, 0b0), (0b000_1011, 0b0),

        (0b000_1100, 0b1_0110011), (0b000_1101, 0b0_000_0001),
        (0b000_1110, 0b00010_0001), (0b000_1111, 0b0000000_0)
    ]

    for addr, instr in instructions:
        dut.uio_in.value = addr  # Set pmAddr
        dut.ui_in.value = instr  # Set instructionIn
        await ClockCycles(dut.clk, 1)  # Wait one cycle per instruction

    # Deassert write enable
    dut.uio_in.value = 0

    # Deassert reset again (ensuring proper start)
    dut.rst_n.value = 1
    dut._log.info("Start execution")

    # Monitor uo_out for a few cycles
    for i in range(9):
        await ClockCycles(dut.clk, 1)
        dut._log.info(f"Cycle {i+1}: uo_out = {dut.uo_out.value}")

    dut._log.info(f"Final output: {dut.uo_out.value}")
