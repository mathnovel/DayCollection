[toc]

----

https://www.cvxpy.org/tutorial/functions/index.html

----

This section of the tutorial describes the atomic functions that can be applied to CVXPY expressions. CVXPY uses the function information in this section and the [DCP rules](https://www.cvxpy.org/tutorial/dcp/index.html#dcp) to mark expressions with a sign and curvature.

```
atomic 原子的
curvature 曲率
```
# 1 Operators
The infix operators <h5>+, -, *, /, @</h5> are treated as **functions**. The operators + and - are always affine functions. The expression **expr1 * expr2** is affine in CVXPY when one of the expressions is constant, and **expr1/expr2** is affine when expr2 is a scalar constant.

Historically, CVXPY used `expr1 * expr2` to denote matrix multiplication. This is now deprecated. Starting with Python 3.5, users can write **expr1 @ expr2** for matrix multiplication and dot products. As of CVXPY version 1.1, we are adopting a new standard:

+ @ should be used for matrix-matrix and matrix-vector multiplication,
+ *should be matrix-scalar and vector-scalar multiplication

Elementwise multiplication can be applied with the multiply function.

```
infix 中缀的
```

## 1.1 Indexing and slicing
Indexing in CVXPY follows exactly the same semantics as NumPy ndarrays. For example, if expr has shape (5,) then expr[1] gives the second entry. More generally, **expr[i:j:k]** selects every kth element of expr, starting at i and ending at j-1. If expr is a matrix, then expr[i:j:k] selects rows, while expr[i:j:k, r:s:t] selects both rows and columns. Indexing drops dimensions while slicing preserves dimensions. For example,

```py
x = cvxpy.Variable(5)
print("0 dimensional", x[0].shape)
print("1 dimensional", x[0:1].shape)
```
```
O dimensional: ()
1 dimensional: (1,)
```

## 1.2 Transpose
The transpose of any expression can be obtained using the syntax expr.T. Transpose is an affine function.

## 1.3 Power
For any CVXPY expression expr, the power operator expr**p is equivalent to the function power(expr, p).


# 2 Scalar functions 
A scalar function takes one or more scalars, vectors, or matrices as arguments and returns a scalar.
<img src="./img/2.png" />
<img src="./img/3.png" />
<img src="./img/4.png" />
<img src="./img/5.png" />

## 2.1 Clarifications for scalar functions
> Clarifications 澄清，说明；净化

The domain S<sup>n</sup> refers to the set of symmetric matrices. The domains 
S<sup>n</sup><sub>+</sub> and S<sup>n</sup><sub>-</sub> refer to the set of positive semi-definite and negative semi-definite matrices, respectively. Similarly, 
S<sup>n</sup><sub>++</sub> and  S<sup>n</sup><sub>--</sub>
 refer to the set of positive definite and negative definite matrices, respectively.

For a vector expression x, norm(x) and norm(x, 2) give the Euclidean norm. For a matrix expression X, however, norm(X) and norm(X, 2) give the spectral norm.

The function norm(X, "fro") is called the [Frobenius norm](https://en.wikipedia.org/wiki/Matrix_norm#Frobenius_norm) and norm(X, "nuc") the nuclear norm. The [nuclear norm](https://en.wikipedia.org/wiki/Matrix_norm#Schatten_norms) can also be defined as the sum of X’s singular values.

The functions max and min give the largest and smallest entry, respectively, in a single expression. These functions should not be confused with maximum and minimum (see [Elementwise functions](https://www.cvxpy.org/tutorial/functions/index.html#elementwise) ). Use maximum and minimum to find the max or min of a list of scalar expressions.

The CVXPY function sum sums all the entries in a single expression. The built-in Python sum should be used to add together a list of expressions. For example, the following code sums a list of three expressions:
```py
expr_list = [expr1, expr2, expr3]
expr_sum = sum(expr_list)
```

# 3 Vector/matrix functions

A vector/matrix function takes one or more scalars, vectors, or matrices as arguments and returns a vector or matrix.

CVXPY is conservative when it determines the sign of an Expression returned by one of these functions. If any argument to one of these functions has unknown sign, then the returned Expression will also have unknown sign. If all arguments have known sign but CVXPY can determine that the returned Expression would have different signs in different entries (for example, when stacking a positive Expression and a negative Expression) then the returned Expression will have unknown sign.
<img src="./img/6.png" />
<img src="./img/7.png" />
<img src="./img/8.png" />