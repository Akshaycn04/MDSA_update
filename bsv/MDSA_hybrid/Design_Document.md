MDSA Hybrid Sorter design document

1) Overview:
This document outlines the implementation of Multi-Dimensional Sorting Array (MDSA) based on the hybrid sorting algorithm as mentioned in the paper “Design of Hybrid Sorting Unit” by Harshini V S and Senthil Kumar K K using Bluespec SystemVerilog (BSV).

2) Hybrid Sorting:
The widely used hardware sorting algorithms in VLSI are Bitonic merge sort and Bitonic odd even sort with 24 and 19 comparator units. While looking at ways to reduce the number of comparators used for sorting, the authors came up with the hybrid sorting algorithm. It makes use of 23 comparators to sort 8 inputs. 
The first two stages of sorting are the same as sorting 4 inputs by splitting 8 inputs into two halves as done in bitonic merge and odd-even sorting networks. In the next stage the maximum of two half of the input is compared. Then the second terms in both have to be compared. When this process goes on at the end of 4th stage and then full 8 inputs are sorted. This sorting algorithm achieves low power consumption due to one less comparator than merge sort. 

3) Modules required to implement the algorithm:
a) Compare and Exchange (CAE) block: is a fundamental building block of Systolic Array based Parallel Hardware Sorters which sorts two inputs to an ascending order output.
b) Sorting method: 8 stages of multiple CAEs each were used to build the sorting network, first two stages are similar to Odd-Even sorter, the difference being it takes only 23 CAE blocks. 
c) MDSA FSM: The control unit is a finite state machine (FSM) that starts in a ‘WAIT’ state and responds to the ‘START’ pulse to begin sorting through six pipeline phases. Each phase is synchronized using a delay counter and guided by a ‘DIRECTION’ signal that alternates between ascending and descending orders. After six phases, the FSM raises the ‘output_enable’ signal to indicate valid sorted output. It then resets to ‘WAIT’ and signals ‘READY’ for the next input sequence.
d) MDSA top module: The top module is the glue,it instantiates, connects, and sequences the sorter units and control logic, interfaces with the outside world, and ensures correct functionality and timing across all stages.

4) BSV Implementation Approach:
Start off with implementing the CAE block in BSV and use it to implement the sorting network. The first two stages will be similar to that of Bitonic merge and Odd-Even sorter. The subsequent stages are then designed as done in the paper. By doing this our sorter unit will be done. Now we can implement the MDSA FSM and finish the implementation after designing the top module. Verification of the design will be done by building a comprehensive testbench. 
After the base implementation is done, we can look at pipelining the design to increase the speed. 

5) Summary
This document details a Bluespec SystemVerilog implementation of the 64-input Hybrid Sorter. It explains the underlying hybrid sorting algorithm, describes each required module, and outlines the control FSM.
