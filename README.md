# This arm sim code adds, subtract and multiply two 32 bit floating point numbers given in a new format.
    1st bit (MSB) : sign bit

    12 bits from MSB : exponent in 2's compliment

    rest 19 bits : mantisa

The file is .s file and can be run on arm simulator.

The code is self explainatory, but for better understanding described below.

Input: The floating point numbers are stored in memory in bytes. Both the inputs are stored one after the another.

## For addition or subtraction of two 32 bits floating point numbers

There are several functions defined in this code.

The first two functions are load1 and laod2. These both functions load the floating point numbers in register r0 and r2 respectively.

Then there are functions that separates mantisa, exponent and sign bit from the loaded inputs.

Then the sign bit is checked and accordingly the sign bit is extended for the exponents. Sign bit is extended because the exponent is in 2's compliment form.

Then the mantisa is added with the significant. Now both the exponents are made same. The expoenet with the greater value is the final expoenet. At the same time the mantisa is also shifted accordingly.

Now seeing the sign bit and mantisa's of both the floating point numbers the addtion is made and sign bit is calculated accordingly. Now the final sig bit is stored in register and final mantisa is send for renormalization.

There is renormalizing function that renormalize the mantisa with 3 different case: 

                   significant is 11
                   
                   significant is 10
                   
                   significant is 00
                   
Now the final floating pointing number is assembled in finalResult function.

Then the same final result is stored in the memory using the storing function.

## For multiplication of two 32 bits floating point numbers

Almost all the steps are same. Here you will not have to make the exponent same. We just have to add the exponents. Now EXOR of sign bit gives the final sign bit.

But the issue in multiplication is that the multiplication of two 20 bits binary number is 40 bits binary number. But our register can only store 32 bits. Therefore we store the result in two registers and exclude the last 8 bits of the final multiplication result. Rest is shifted to a single register and then it is renormalized using the same renormalize function.

Then the final floating point number is created using the final sign bit, mantisa and exponent. Then final it is stored at the input memory loaction back.

It is to be kept in mind that the code does not adds denormalized floating point numbers. Also there are loops where a number is created for bit extraction, mantisa extraction and all. This can also be done by storing those numbers to a memory and then using it when by loading it to a register.
