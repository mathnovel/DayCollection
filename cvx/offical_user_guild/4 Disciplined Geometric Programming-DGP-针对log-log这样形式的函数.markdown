
[toc]

-----

https://www.cvxpy.org/tutorial/dgp/index.html

---

Disciplined geometric programming (DGP) is an analog of DCP for log-log convex functions, that is, functions of positive variables that are convex with respect to the geometric mean instead of the arithmetic mean.

While DCP is a ruleset for constructing convex programs, DGP is a ruleset for log-log convex programs (LLCPs), which are problems that are convex after the variables, objective functions, and constraint functions are replaced with their logs, an operation that we refer to as a log-log transformation. Every geometric program (GP) and generalized geometric program (GGP) is an LLCP, but there are LLCPs that are neither GPs nor GGPs.

CVXPY lets you form and solve DGP problems, just as it does for DCP problems. For example, the following code solves a simple geometric program,

```py
import cvxpy as cp

# DGP requires Variables to be declared positive via `pos=True`.
x = cp.Variable(pos=True)
y = cp.Variable(pos=True)
z = cp.Variable(pos=True)

objective_fn = x * y * z
constraints = [
  4 * x * y * z + 2 * x * z <= 10, x <= 2*y, y <= 2*x, z >= 1]
problem = cp.Problem(cp.Maximize(objective_fn), constraints)
problem.solve(gp=True)
print("Optimal value: ", problem.value)
print("x: ", x.value)
print("y: ", y.value)
print("z: ", z.value)

```
and it prints the below output.

```
Optimal value: 1.9999999938309496
x: 0.9999999989682057
y: 1.999999974180587
z: 1.0000000108569758
```
Note that to solve DGP problems, you must pass the option gp=True to the solve() method.

This section explains what DGP is, and it shows how to construct and solve DGP problems using CVXPY. At the end of the section are tables listing all the atoms that can be used in DGP problems, similar to the tables presented in the section on [DCP atoms](https://www.cvxpy.org/tutorial/functions/index.html#functions).

For an in-depth reference on DGP, see our [accompanying paper](https://web.stanford.edu/~boyd/papers/dgp.html). For interactive code examples, check out our [notebooks](https://www.cvxpy.org/examples/index.html#dgp-examples).

Note: DGP is a recent addition to CVXPY. If you have feedback, please file an issue or make a pull request on [Github](https://github.com/cvxpy/cvxpy).

# 1 Log-log curvature
<img src="./img/13.png" />
<img src="./img/14.png" />

已知的 log-log曲线函数，链接打不开了。[atoms with known log-log curvature ](https://www.cvxpy.org/tutorial/dgp/dgp-atoms)

CVXPY’s log-log curvature analysis can flag Expressions as unknown even when they are log-log convex or log-log concave. Note that any log-log constant expression is also log-log affine, and any log-log affine expression is log-log convex and log-log concave.

The log-log curvature of an Expression is stored in its **.log_log_curvature** attribute. For example, running the following script

```py
import cvxpy as cp

x = cp.Variable(pos=True)
y = cp.Variable(pos=True)

constant = cp.Constant(2.0)
monomial = constant * x * y
posynomial = monomial + (x ** 1.5) * (y ** -1)
reciprocal = posynomial ** -1
unknown = reciprocal + posynomial

print(constant.log_log_curvature)
print(monomial.log_log_curvature)
print(posynomial.log_log_curvature)
print(reciprocal.log_log_curvature)
print(unknown.log_log_curvature)

```

prints the following output.
```
LOG-LOG CONSTANT
LOG-LOG AFFINE
LOG-LOG CONVEX
LOG-LOG CONCAVE
UNKNOWN
```
You can also check the log-log curvature of an Expression by calling the methods **is_log_log_constant(), is_log_log_affine(), is_log_log_convex(), is_log_log_concave()**. For example, posynomial.is_log_log_convex() would evaluate to True.

# 2 Log-log curvature rules
<img src="./img/15.png" />

```py
import cvxpy as cp

x = cp.Variable(pos=True)
y = cp.Variable(pos=True)

monomial = 2.0 * constant * x * y
posynomial = monomial + (x ** 1.5) * (y ** -1)

assert monomial.is_dgp()
assert posynomial.is_dgp()
```

An Expression is DGP precisely when it has known log-log curvature, which means at least one of the methods is_log_log_constant(), is_log_log_affine(), is_log_log_convex(), is_log_log_concave() will return True.

# 3 DGP problems
A Problem is constructed from an objective and a list of constraints. If a problem follows the DGP rules, it is guaranteed to be an LLCP and solvable by CVXPY. The DGP rules require that the problem objective have one of two forms:
+ Minimize(log-log convex)
+ Maximize(log-log concave)

The only valid constraints under the DGP rules are
+ log-log affine == log-log affine
+ log-log convex <= log-log concave
+ log-log concave >= log-log convex
  
You can check that a problem, constraint, or objective satisfies the DGP rules by calling object.is_dgp(). Here are some examples of DGP and non-DGP problems:

```py
import cvxpy as cp

# DGP requires Variables to be declared positive via `pos=True`.
x = cp.Variable(pos=True)
y = cp.Variable(pos=True)
z = cp.Variable(pos=True)

objective_fn = x * y * z
constraints = [
  4 * x * y * z + 2 * x * z <= 10, x <= 2*y, y <= 2*x, z >= 1]
assert objective_fn.is_log_log_concave()
assert all(constraint.is_dgp() for constraint in constraints)
problem = cp.Problem(cp.Maximize(objective_fn), constraints)
assert problem.is_dgp()

# All Variables must be declared as positive for an Expression to be DGP.
w = cp.Variable()
objective_fn = w * x * y
assert not objective_fn.is_dgp()
problem = cp.Problem(cp.Maximize(objective_fn), constraints)
assert not problem.is_dgp()

```
CVXPY will raise an exception if you call problem.solve(gp=True) on a non-DGP problem.

# 4 DGP atoms 构成DGP的原子函数以及符合DGP的操作符

This section of the tutorial describes the DGP atom library, that is, the atomic functions with known log-log curvature and monotonicity. CVXPY uses the function information in this section and the DGP rules to mark expressions with a log-log curvature. Note that every DGP expression is positive.

## 4.1 Infix operators
The infix operators +, *, / are treated as atoms. The operators * and / are log-log affine functions. The operator + is log-log convex in both its arguments.

Note that in CVXPY, expr1 * expr2 denotes matrix multiplication when expr1 and expr2 are matrices; if you’re running Python 3, you can alternatively use the @ operator for matrix multiplication. Regardless of your Python version, you can also use the matmul atom to multiply two matrices. To multiply two arrays or matrices elementwise, use the multiply atom. Finally, to take the product of the entries of an Expression, use the prod atom.

## 4.2 Transpose
The transpose of any expression can be obtained using the syntax expr.T. Transpose is a log-log affine function.

## 4.3 Power
For any CVXPY expression expr, the power operator expr**p is equivalent to the function power(expr, p). Taking powers is a log-log affine function.

## 4.4 Scalar functions
A scalar function takes one or more scalars, vectors, or matrices as arguments and returns a scalar. Note that several of these atoms may be applied along an axis; see the API reference or the [DCP atoms](https://www.cvxpy.org/tutorial/functions/index.html#functions) tutorial for more information.

<img src="./img/16.png" />
<img src="./img/17.png" />
<img src="./img/18.png" />

## 4.5 Elementwise functions 逐个元素操作的函数
These functions operate on each element of their arguments. For example, if X is a 5 by 4 matrix variable, then sqrt(X) is a 5 by 4 matrix expression. sqrt(X)[1, 2] is equivalent to sqrt(X[1, 2]).

Elementwise functions that take multiple arguments, such as maximum and multiply, operate on the corresponding elements of each argument. For example, if X and Y are both 3 by 3 matrix variables, then maximum(X, Y) is a 3 by 3 matrix expression. maximum(X, Y)[2, 0] is equivalent to maximum(X[2, 0], Y[2, 0]). This means all arguments must have the same dimensions or be scalars, which are promoted.

<img src="./img/19.png" />

## 4.6 Vector/matrix functions
A vector/matrix function takes one or more scalars, vectors, or matrices as arguments and returns a vector or matrix.

<img src="./img/20.png" />
<img src="./img/21.png" />