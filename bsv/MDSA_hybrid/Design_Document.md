MDSA Hybrid Sorter design document

1) Overview
This document outlines the implementation of Multi-Dimensional Sorting Array (MDSA) based on the hybrid sorting algorithm as mentioned in the paper “Design of Hybrid Sorting Unit” by Harshini V S and Senthil Kumar K K using Bluespec SystemVerilog (BSV). It also looks at implementing the pipelined version of the sorter to improve the speed.

2) Hybrid Sorting
The widely used hardware sorting algorithms in VLSI are Bitonic merge sort and Bitonic odd even sort with 24 and 19 comparator units. While looking at ways to reduce the number of comparators used for sorting, the authors came up with the hybrid sorting algorithm. It makes use of 23 comparators to sort 8 inputs. 
The first two stages of sorting are the same as sorting 4 inputs by splitting 8 inputs into two halves as done in bitonic merge and odd-even sorting networks. In the next stage the maximum of two half of the input is compared. Then the second terms in both have to be compared. When this process goes on at the end of 4th stage and then full 8 inputs are sorted. This sorting algorithm achieves low power consumption due to one less comparator than merge sort. 

3) Modules required to implement the algorithm
a) Compare and Exchange (CAE) block: is a fundamental building block of Systolic Array based Parallel Hardware Sorters which sorts two inputs to an ascending order output.
b) Sorting Units: As mentioned in the paper, the first stage uses OE-2 input sorter, the second stage uses OE-4 input sorter and the subsequent stages use the OE-8 sorter unit. I think that we can also use BM-2, BM-4 and BM-8 units to implement the hybrid sorting network if we are planning to scale beyond 8 inputs since it scales better than OE units as per my understanding. If we plan to optimize the area then OE units will be better than BM units.
c) MDSA FSM: The control unit is a finite state machine (FSM) that starts in a ‘WAIT’ state and responds to the ‘START’ pulse to begin sorting through six pipeline phases. Each phase is synchronized using a delay counter and guided by a ‘DIRECTION’ signal that alternates between ascending and descending orders. After six phases, the FSM raises the ‘output_enable’ signal to indicate valid sorted output. It then resets to ‘WAIT’ and signals ‘READY’ for the next input sequence.
d) MDSA top module: The top module is the glue,it instantiates, connects, and sequences the sorter units and control logic, interfaces with the outside world, and ensures correct functionality and timing across all stages.

4) BSV Implementation Approach
Start off with implementing the CAE block in BSV and use it to implement the sorting network. The first two stages will be similar to that of Bitonic merge and Odd-Even sorter. The subsequent stages are then designed as done in the paper. By doing this our sorter unit will be done. Now we can implement the MDSA FSM and finish the implementation after designing the top module. Verification of the design will be done by building a comprehensive testbench. 
After the base implementation is done, we can look at pipelining the design to increase the speed. 

5) Scope for Improvement
The proposed hybrid sorter consumes less power than bitonic merge but it is slower. Thus, to improve the speed of the design a pipelined architecture has been proposed which triples the speed of the design. High speed is achieved by introducing three stages of pipelining and provides better performance than existing one when the bit width of input increases.

6) Summary
This document details a Bluespec SystemVerilog implementation of the 64-input Hybrid Sorter. It explains the underlying hybrid sorting algorithm, describes each required module, and outlines the control FSM. Finally, it highlights how three-stage pipelining can further boost speed.
