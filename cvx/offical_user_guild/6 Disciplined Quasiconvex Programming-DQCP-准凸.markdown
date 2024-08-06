
[toc]

----

https://www.cvxpy.org/tutorial/dqcp/index.html


---


Disciplined quasiconvex programming (DQCP) is a generalization of DCP for quasiconvex functions. Quasiconvexity generalizes convexity: a function is quasiconvex if and only if its domain is a convex set and its sublevel sets {x:(f(x)<=t} are convex, for all . For a thorough overview of quasiconvexity, see the paper [Disciplined quasiconvex programming](https://web.stanford.edu/~boyd/papers/dqcp.html).


While DCP is a ruleset for constructing convex programs, DQCP is a ruleset for quasiconvex programs (QCPs), which are optimization problems in which the objective is to minimize a quasiconvex function over a convex set. The convex set can be specified using equalities of affine functions and inequalities of convex and concave functions, just as in DCP; additionally, DQCP permits inequalities of the form `f(x) <= t`, where f(x) is a quasiconvex expression and `t`  is constant, and f(x)>=t , where f(x) is quasiconcave and `t` is constant. Every disciplined convex program is a disciplined quasiconvex program, but the converse is not true.

CVXPY lets you form and solve DQCP problems, just as it does for DCP problems. For example, the following code solves a simple QCP,

```py
import cvxpy as cp

x = cp.Variable()
y = cp.Variable(pos=True)
objective_fn = -cp.sqrt(x) / y
problem = cp.Problem(cp.Minimize(objective_fn), [cp.exp(x) <= y])
problem.solve(qcp=True)
assert problem.is_dqcp()
print("Optimal value: ", problem.value)
print("x: ", x.value)
print("y: ", y.value)

```

and it prints the below output.
```
Optimal value:  -0.4288821220397949
x:  0.49999737143004713
y:  1.648717724845007
```

This section explains what DQCP is, and it shows how to construct and solve DQCP problems using CVXPY. At the end of the section are tables listing all the atoms that can be used in DQCP problems, similar to the tables presented in the section on [DCP atoms](https://www.cvxpy.org/tutorial/functions/index.html#functions).

For an in-depth reference on DQCP, see our [accompanying paper](https://web.stanford.edu/~boyd/papers/dqcp.html). For interactive code examples, check out our [notebooks](https://www.cvxpy.org/examples/index.html#dqcp-examples).

Note: DQCP is a recent addition to CVXPY. If you have feedback, please file an issue or make a pull request on [Github](https://github.com/cvxpy/cvxpy).

# 1 Curvature¶
DQCP adds two new types of curvature to CVXPY: quasiconvex and quasiconcave. A function `f`  is quasiconvex if and only if its domain is a convex set and its sublevel sets {x| f(x)<=t } are convex, for all t; `f` is quasiconcave if `-f` is quasiconvex. Every convex function is also quasiconvex, and every concave function is also quasiconcave; the converses of these statements are not true. An expression that is both quasiconvex and quasiconcave is called quasilinear.


CVXPY’s curvature analysis can flag Expressions as unknown even when they are quasiconvex or quasiconcave, but it will never mistakenly flag an expression as quasiconvex or quasiconcave.

The curvature of an Expression is stored in its `.curvature` attribute. For example, running the following script

```py
import cvxpy as cp

x = cp.Variable(3)
y = cp.length(x)
z = -y
print(y.curvature)
print(z.curvature)

w = cp.ceil(x)
print(w.curvature)
```
prints the following output.
```
QUASICONVEX
QUASICONCAVE
QUASILINEAR
```

You can also check the curvature of an Expression by calling the methods `is_quasiconvex()` and `is_quasiconcave()`. For example, y.`is_quasiconvex()` and `z.is_quasiconcave()` would evaluate to True. You can check if an expression is quasilinear by calling the `is_quasilinear()` method.

# 2 Composition rules
DQCP analysis is based on applying a general composition theorem from convex analysis to each expression. 

An expression is verifiably **quasiconvex** under DQCP if it is one of the following:

+ convex (under DCP);
+ a quasiconvex atom, applied to a variable or constant:
+ the max (cvxpy.maximum) of quasiconvex expressions;
+ an increasing function of a quasiconvex expression, or a decreasing function of a quasiconcave expression;
+ an expression of the form f(e1,e2,...,en) such that:
+ 1.  f is a quasiconvex atom, and 
+ 2.  for each i f is increasing in argument and e<sub>i</sub> is convex, f is decreasing in argument and e<sub>i</sub> is concave, or e<sub>i</sub>  is affine.

An expression is **quasiconcave** under DQCP if it is one of the following:
+ concave (under DCP);
+ a quasiconcave atom, applied to a variable or constant:
+ the min (cvxpy.minimum) of quasiconcave expressions;
+ an increasing function of  a quasiconcave expression, or a decreasing function of a quasiconvex expression;
+ an expression of the form   f(e1,e2,...,en) such that:
+ 1. f is a quasiconcave atom, and 
+ 2.  for each i, f is increasing in argument `i` and e<sub>i</sub> is concave, f is decreasing in argument `i` and e<sub>i</sub> is convex, or is affine.
Whether an atom is quasiconvex or quasiconcave may depend on the signs of its arguments. For example, the scalar product `xy` is quasiconcave when x and y are either both nonnegative or both nonpositive, and quasiconvex when one the arguments is nonnegative and the other is nonpositive.

If an Expression satisfies the above rules, we colloquially say that the Expression “is DQCP.” You can check whether an Expression is DQCP by calling the method `is_dqcp()`. For example, the assertions in the following code block will pass.

```py
import cvxpy as cp

x = cp.Variable(pos=True)
y = cp.Variable(pos=True)

product = cp.multiply(x, y)

assert product.is_quasiconcave()
assert product.is_dqcp()
```

An Expression is DQCP precisely when it has known curvature, which means at least one of the methods is_constant() is_affine(), is_convex(), is_concave(), is_quasiconvex(), is_quasiconvex() will return True.

# 3 DQCP problems
A Problem is constructed from an objective and a list of constraints. If a problem follows the DQCP rules, it is guaranteed to be a DQCP and solvable by CVXPY (if a solution to the problem exists). The DQCP rules require that the problem objective have one of two forms:

+ Minimize(quasiconvex)
+ Maximize(quasiconcave)

The only valid constraints under the DQCP rules are
+ affine == affine
+ convex <= concave
+ concave >= convex
+ quasiconvex <= constant
+ quasiconcave >= constant

You can check that a problem, constraint, or objective satisfies the DQCP rules by calling object.is_dqcp(). Here are some examples of DQCP and non-DQCP problems:

```py
import cvxpy as cp

# The sign of variables affects curvature analysis.
x = cp.Variable(nonneg=True)
concave_fractional_fn = x * cp.sqrt(x)
constraint = [cp.ceil(x) <= 10]
problem = cp.Problem(cp.Maximize(concave_fractional_fn), constraint)
assert concave_fractional_fn.is_quasiconcave()
assert constraint[0].is_dqcp()
assert problem.is_dqcp()

w = cp.Variable()
fn = w * cp.sqrt(w)
problem = cp.Problem(cp.Maximize(fn))
assert not fn.is_dqcp()
assert not problem.is_dqcp()

```

CVXPY will raise an exception if you call problem.solve(qcp=True) on a non-DQCP problem.



# 4 DQCP atoms

Quasiconvex and quasiconcave expressions can be constructed using convex and concave atoms, using the curvature rules given above. This section describes new semantics for some existing atoms under DQCP, and introduces new atoms that are quasiconvex or quasiconcave (but not convex or concave). Many of these new atoms are integer-valued.

## 4.1 Ratio. 
The infix operator `/` is an atom, denoting ratio. This atom is both quasiconvex and quasiconcave when the denominator is known to be either nonnegative or nonpositive. The ratio x/y is increasing in x when y is nonnegative, increasing in y when x is nonpositive, decreasing in x when y is nonpositive, and decreasing in y when x is nonnegative.
The ratio atom can be used with the composition rule to construct interesting quasiconvex and quasiconcave expressions. For example, the ratio of a nonnegative concave function and a positive convex function is quasiconcave, and the ratio of a nonnegative convex function and a positive concave function is quasiconvex. Similarly, the ratio of two affine functions is quasilinear when the denominator is positive.

## 4.2 Scalar product. 

The scalar product `*` is quasiconvex when one of its arguments is nonnegative and the other is nonpositive, and it is quasiconcave when its arguments are both nonnegative or both nonpositive. Hence, by the composition rule, the product of two nonnegative concave functions is quasiconcave, and the product of a nonnegative concave function and a nonpositive convex function is quasiconvex.

## 4.3 Distance ratio function. 

The atom `cvxpy.dist_ratio(x, a, b)` denotes the function ||x -a||<sub>2</sub> - ||x -b ||<sub>2</sub>, implicitly enforcing the constraint that <sub>2</sub> <= ||x -b ||<sub>2</sub>. The expressions a and b must be constants. This atom is quasiconvex.

## 4.4 Maximum generalized eigenvalue

The atom `cvxpy.gen_lambda_max(A, B)` computes the maximum generalized eigenvalue of A and B, defined as the maximum  $\lambda$ $\in$ R such that Ax =  $\lambda$Bx for some x. This atom is quasiconvex, and it enforces the constraint that A is symmetric and B is positive definite.

## 4.5 Condition Number. 
he atom `cvxpy.condition_number(A)` computes the condition number of A, defined as the $\lambda$<sub>max</sub>(A)/$\lambda$<sub>min</sub>(A) . This atom is quasiconvex, and it enforces the constraint that A is symmetric and positive definite.

## 4.6 Ceiling and floor. 

The atoms `cvxpy.ceil(x) and cvxpy`.floor(x) are quasilinear, and increasing in their arguments.

## 4.7 Sign. 
The atoms `cvxpy.sign(x)`, which returns -1 for x <= 0 and +1 for x > 0, is quasilinear.

## 4.7 Length of a vector. 
The atoms `cvxpy.length(x)`, which returns the index of the last nonzero element in  x $\in$ R<sup>n</sup>, is quasiconvex.

# 5 Solving DQCP problems
A DQCP problem problem can be solved by calling problem.solve(qcp=True). CVXPY uses a bisection method on the optimal value of the problem to solve QCPs, and it will automatically find an upper and lower bound for the bisection. You can optionally provide your own upper and lower bound when solving a QCP, which can sometimes be helpful. You can provide these bounds via the keyword arguments low and high; for example, problem.solve(qcp=True, low=12, high=17) would limit the bisection to objective values that are greater than 12 and less than 17.

Bisection involves solving a sequence of optimization problems. If your problem is ill-conditioned, or if you’re unlucky, a solver might fail to solve one of these subproblems, which will result in an error. If this happens, you can try using a different solver via the solver keyword argument. (For example, problem.solve(qcp=True, solver=cp.SCS).) To obtain verbose output describing the bisection, supply the keyword argument verbose=True to the solve method (problem.solve(qcp=True, verbose=True)).