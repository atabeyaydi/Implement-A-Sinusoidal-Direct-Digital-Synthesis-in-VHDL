## How to Implement a sinusoidal DDS in VHDL

### What is a sinusoidal Direct Digital Synthesis (DDS)?
 The Direct Digital Synthesis (DDS) is a method of producing an analog waveform using a digital device. In this post, we are going to illustrate how to generate digitally a sine-wave using a digital device such as FPGA or ASIC.
 
The sine/cosine wave generated can be used inside your digital design in order to perform digital up/down frequency conversion. This technique is used, for example, in the modern DAC to perform digital upsampling after signal interpolation. The interpolated DAC 5687 from Texas Instruments is an example. 

Since the operations are digital, the DDS offers fast switching between output frequencies, fine frequency resolution, and operation over a broad spectrum of frequencies. If you need to generate an analog waveform a digital-to-analog conversion is required.

There are many devices ready-to-use that implement DDS to generate a programmable sinusoidal wave. An example is the AD9837 from Analog Devices a low power, programmable waveform generator capable of producing sine, triangular, and square wave outputs.

As clear, the 10-bit DAC can be driven either with SIN ROM output generating a sine wave or from the MSB of the NCO i.e. a programmable saw tooth.

 ### DDS use in digital processing
We dealt about the first step in DDS implementation i.e. the phase accumulator. In order to implement a sinusoidal wave generator, we need to implement the phase-to-amplitude conversion. This can be done basically in two different way:

- Using a Look-Up-Table (LUT);
- Using a Cordic

In both cases, the MSB of the NCO phase accumulator are used to address the phase-to-amplitude block.
In the DDS architecture, we need first an NCO. Generally, the number of bist used in the NCO quantization is in the range of 24-48 bit. For a 32 bit quantization, the frequency resolution of the NCO is Fc/232, where Fc is the clock frequency of the system.

The MSB of the NCO accumulator is used to address the sine table or to provide the phase control word for the cordic. The phase errors introduced by truncating the NCO accumulator will result in errors in amplitude during the phase-to-amplitude conversion process inherent in the DDS. The NCO wraps around cyclically so these truncation errors are periodic. Since these amplitude errors are periodic in the time domain, they appear as line spectra (spurs) in the frequency domain and are what is known as phase truncation spurs.

The magnitude and distribution of phase truncation spurs dependent on three aspects:
- number of bit of the NCO Accumulator (NBIT);
- number of bit of the “Phase word” (NPHASE) i.e., the number of bits used for LUT addressing
- FWC value

### Spur Magnitude due to the phase truncation
Some FCW yield no phase truncation spurs at all while others yield spurs with the maximum possible level. If the value NBIT-NPHASE>4 (this is the typical situation in DDS design), then the maximum spur level turns out to be very closely approximated by
–6.02 x NPHASE dBc.
For instance, 32-bit NCO with a 12-bit phase word results in phase truncation spurs of no more than –72dBc regardless of the tuning word chosen: 16*6 = 72

### Implement a sinusoidal wave in VHDL using a DDS
So, it is the time to see an example of VHDL implementation of a digital sinusoidal generator.
- NCO
- LUT containing sine sample
- 
The LUT can be generated using the strategy discussed in this post. So, we initialize a constant with the sine sample directly generated in VHDL. Note that you can use this code in your FPGA implementation since the synthesizer can initialize the LUT and implement a ROM with the sine sample as we will see in next in this section with an example using Altera Quartus II.

The VHDL of the DDS implements a sine wave generator using an NCO 32 bit wide with programmable FCW and start phase. The sine LUT is generated using the initialization function “init_lut_sin”. The sine samples are quantized at 14 bit and can be straight connected to a DAC digital input. The LUT length is 8K word@ 14 bit so we need to use the 13 MSB from the NCO to address the LUT input.

In the VHDL of the DDS for the sine generator, we used two functions:
* the first quantize_sgn is used to quantize the floating-point value of the sine to a fixed-point value at 14 bits;
* the second function init_lut_sin aims to initialize the constant C_LUT_SIN. The constant C_LUT_SIN is defined as an array of std_logic_vector, this should trigger the synthesizer to map the constant into a ROM.

We should always verify if the constant has been mapped into a ROM macro. If not, we are wasting a huge amount of FPGA logic.

### Layout the VHDL code of DDS on Quartus II
In this VHDL implementation of the DDS, the process p_rom do not use the asynchronous reset. It could depend on the technology you are using: the compiler can map a structure into the dedicated hardware only if such hardware macro is available in the silicon, in the other case, the VHDL compiler will try to implement the functionality with the available logic. Using a process with reset Quartus II doesn’t map the C_LUT_SIN constant into a ROM but uses internal FPGA logic. Using this approach the C_LUT_SIN is mapped into a ROM as clear  where is reported the FITTER report: the ROM is initialized with the “dds_sine.dds_sine0.rtl.mif” file self-generated by Quartus II.

If we want to perform an extra check, we can verify that the ROM mapped into the FPGA is initialized correctly checking the initialization file versus the C_LUT_SIN constant visible in the “Locals” of ModelSim simulation. There is reported the head and tail of the Altera ROM initialization MIF file versus ModelSim simulation of the constant containing the sine table value. As clear the two values match.

### Simulation of the VHDL DDS implementation with programmable start phase
In the simulation, the test bench instantiates two identical DDS. The DDS are programmed with the same FCW such and different start phase. In the example, the system clock is 10 ns i.e. 100 MHz. 
- The FCW is programmed to generate a sine wave of 1 MHz: FCW = 1/100 *2^32 = 0x028F5C28      EQ.2
- The phase offset is: 180/360 * 2^32 = 0x80000000

For example, using more than a DDS with different phase offset you can implement a Digital Beam Forming network. This architecture is widely used in telecommunication to move digitally the antenna beam during transmission.

There is represented the simulation of two DDS generating a sinusoidal wave of 1 MHz. The system clock is 100 MHz so the sine wave contains 100 sample per period. It can be observed from the very smooth wave in the simulation. The mutual phase shift is 180°.

### Conclusion
We addressed the VHDL realization of a sinusoidal DDS. The VHDL code is fully synthesizable on FPGA and ASIC. By the way, using the approach of table computation using initialization function we must verify the correct implementation of the LUT on silicon.

Reference:
1. “A Technical Tutorial on Digital Signal Synthesis” Analog Devices
2. “All About Direct Digital Synthesis” Analog Devices
3. “Direct Digital Synthesizers: Theory, Design and Applications” Jouko Vankka, Helsinki University of Technology
