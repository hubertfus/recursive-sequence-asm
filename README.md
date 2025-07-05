# **Recursive Sequence Calculator (Assembly, x86, 32-bit)**

## **Overview**

This program calculates the value of a specific recursive sequence defined as:

* `seq(1) = 3`
* `seq(2) = 4`
* `seq(n) = 0.5 * seq(n - 1) + 2 * seq(n - 2)` for `n > 2`

The program is implemented in x86 assembly (32-bit), using floating-point operations with the x87 FPU stack. It interacts with the user through standard I/O functions (`printf`, `scanf`, `getchar`) provided by the C standard library or an external API table.

---

## **Functionality**

1. Prompts the user to enter an integer `n` (must be ≥ 1).
2. Validates the input (checks for correct number and newline character).
3. Computes the value of `seq(n)` recursively using floating-point operations.
4. Displays the result as a floating-point number.
5. Terminates after displaying the result.

---

## **Key Components**

* **Recursive Calculation (Function ****************`seq`****************)**

  * Computes the sequence recursively.
  * Uses the FPU stack for floating-point math:

    * Multiplication, addition, division.
  * Optimized for base cases (`n = 1` and `n = 2`).

* **Input Validation**

  * Ensures the user enters a valid integer followed by Enter (`'\n'`).
  * Clears invalid input from the buffer.

* **Output Formatting**

  * Displays the result in the format: `seq(n) = <result>`.

---

## **Compilation (Windows)**

```bash
nasm r_sequence-exe.asm -o r_sequence-exe.o -f win32
gcc r_sequence-exe.o -o r_sequence-exe.exe -m32
```

---

## **Example Usage**

```
n = 7
seq(7) = 61.500000
```

---

## **Notes**

* Requires a 32-bit environment (`-m32` flag in GCC).

* Uses floating-point math; results are displayed in double precision.

* Can be easily integrated into an API-based asmloader (via `EBX` table).

* Designed mainly for educational purposes (recursion, FPU, input handling in assembly).

* There are **three versions** of this program:

  1. Standalone executable version.
  2. Version for **asmloader** using the **NASM** assembler.
  3. Version for **asmloader** written in **C**.

* You can find **asmloader** here: [https://github.com/gynvael/asmloader](https://github.com/gynvael/asmloader)
