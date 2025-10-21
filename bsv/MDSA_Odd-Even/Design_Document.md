MDSA Odd-Even Sorter Design Document       
1. Overview
This document outlines the Bluespec SystemVerilog (BSV) implementation of a Multi-Dimensional Sorting Array (MDSA) based on the odd-even sorting algorithm. The design targets an 8×8 matrix of 32-bit values, sorting them through multiple stages using a highly parallel architecture. Unlike the bitonic sorter, this approach relies on an odd-even transposition network, which is straightforward and suitable for hardware implementation.
2. Architecture Components
2.1 Compare-and-Swap (CAS) Module
- Core primitive that compares two values and swaps them depending on the specified sorting direction.
- Configurable for different data widths with pipelined (registered) outputs.
- Supports ascending and descending operations.

2.2 Odd-Even Network (OEN) Module
- Implements a 6-stage sorting network tailored to an 8-element vector.
- Composed of CAS units arranged in an odd-even structure for each stage.
- Operates on either rows or columns of the matrix.

2.3 MDSA Sorter Module
- Contains eight parallel instances of the OEN module for row or column-wise sorting.
- Manages data transposition between stages to alternate row and column sorting.
- Includes feedback mechanisms for iterative processing across multiple phases.

2.4 MDSA FSM (Finite State Machine)
- Controls the sorting sequence through a six-phase process.
- Drives direction control signals and synchronizes matrix transpositions.
- Generates valid and ready signals for data output.

2.5 MDSA Top Module
- Integrates all submodules into a unified system.
- Exposes a clean top-level interface for system integration.

3. BSV Implementation Approach
The implementation starts by defining fixed-width data types and FSM states to ensure clarity and type safety. The Compare-and-Swap (CAS) unit is designed as a pipelined, reusable module with registered outputs. These CAS units are connected to form the Odd-Even Network (OEN), which handles sorting for each row or column using rule-based logic.
The sorter module uses multiple OENs in parallel and manages matrix transposition with BSV’s functional tools like map and transpose. Registers and rules control the feedback between sorting phases. An FSM manages the overall sorting flow using counters and conditions. At the top level, all modules are integrated with a clean interface, supporting modularity and efficient hardware generation.

4. Implementation Considerations
-  Rule-Based Parallelism
BSV's rule-driven model naturally supports concurrent operations, making it ideal for expressing parallel sorting stages. Each compare-and-swap operation is atomic, allowing multiple units to operate simultaneously without manual scheduling.
-  Strong Typing & Modularity
BSV's strong static typing ensures safer hardware composition and easier reuse. The MDSA design is broken into cleanly defined modules (CAS, OEN, Sorter, FSM), improving readability and reducing design errors.
-  Efficient Hardware Mapping
The design optimizes pipeline depth, parallelism, and synchronization—resulting in high throughput while maintaining correctness. Functional constructs simplify data transposition and configuration, contributing to both performance and clarity.

5. Summary
The BSV implementation of the MDSA Odd-Even sorter offers a modular, parallel, and type-safe architecture that improves upon traditional Verilog-based approaches. By utilizing BSV’s rule-driven semantics and functional abstraction, the design achieves enhanced maintainability and clarity while ensuring performance parity with its RTL counterpart.
