https://www.cvxpy.org/tutorial/constraints/index.html

-----

[toc]

----

# 1 Attributes


Variables and parameters can be created with attributes specifying additional properties. For example, Variable(nonneg=True) is a scalar variable constrained to be nonnegative. Similarly, Parameter(nonpos=True) is a scalar parameter constrained to be nonpositive. The full constructor for **Leaf** (the parent class of Variable and Parameter) is given below.

>**Leaf**(shape=None, value=None, nonneg=False, nonpos=False, complex=False, imag=False, symmetric=False, diag=False, PSD=False, NSD=False, hermitian=False, boolean=False, integer=False, sparsity=None, pos=False, neg=False)

>Leaf是Variable和Parameter的父类

Creates a Leaf object (e.g., Variable or Parameter). Only one attribute can be active (set to True).


## 1.1 Parameters:
+ shape (tuple or int) – The variable dimensions (0D by default). Cannot be more than 2D.

+ value (numeric type) – A value to assign to the variable.

+ nonneg (bool) – Is the variable constrained to be nonnegative?

+ nonpos (bool) – Is the variable constrained to be nonpositive?

+ complex (bool) – Is the variable constrained to be complex-valued?

+ imag (bool) – Is the variable constrained to be imaginary?

+ symmetric (bool) – Is the variable constrained to be symmetric?

+ diag (bool) – Is the variable constrained to be diagonal?

+ PSD (bool) – Is the variable constrained to be symmetric positive semidefinite?

+ NSD (bool) – Is the variable constrained to be symmetric negative semidefinite?

+ hermitian (bool) – Is the variable constrained to be Hermitian?

+ boolean (bool or list of tuple) – Is the variable boolean (i.e., 0 or 1)? True, which constrains the entire variable to be boolean, False, or a list of indices which should be constrained as boolean, where each index is a tuple of length exactly equal to the length of shape.

+ integer (bool or list of tuple) – Is the variable integer? The semantics are the same as the boolean argument.

+ sparsity (list of tuplewith) – Fixed sparsity pattern for the variable.

+ pos (bool) – Is the variable constrained to be positive?

+ neg (bool) – Is the variable constrained to be negative?

+ bounds (iterable of length two) – Is the variable bounded below and/or above?

The `value` field of Variables and Parameters can be assigned a value after construction, but the assigned value must satisfy the object attributes. A Euclidean projection onto the set defined by the attributes is given by the `project` method.

```py
p = Parameter(nonneg=True)
try:
    p.value = -1
except Exception as e:
    print(e)

print("Projection:", p.project(-1))

```

```
Parameter value must be nonnegative.
Projection: 0.0
```

A sensible idiom for assigning values to leaves is `leaf.value = leaf.project(val)`, ensuring that the assigned value satisfies the leaf’s properties. A slightly more efficient variant is `leaf.project_and_assign(val)`, which projects and assigns the value directly, without additionally checking that the value satisfies the leaf’s properties. In most cases `project` and checking that a value satisfies a leaf’s properties are cheap operations (i.e., 
), but for symmetric positive semidefinite or negative semidefinite leaves, the operations compute an eigenvalue decomposition.

Many attributes, such as nonnegativity and symmetry, can be easily specified with constraints. What is the advantage then of specifying attributes in a variable? The main benefit is that specifying attributes enables more fine-grained DCP analysis. For example, creating a variable x via x = Variable(nonpos=True) informs the DCP analyzer that x is nonpositive. Creating the variable x via x = Variable() and adding the constraint x >= 0 separately does not provide any information about the sign of x to the DCP analyzer.

>**Important:**
One downside of using attributes over explicit constraints is that dual variables will not be recorded. Dual variable values are only recorded for explicit constraints.

# 2 Semidefinite matrices

Many convex optimization problems involve constraining matrices to be positive or negative semidefinite (e.g., SDPs). You can do this in CVXPY in two ways. The first way is to use Variable((n, n), PSD=True) to create an n by n variable constrained to be symmetric and positive semidefinite. For example,

```py
# Creates a 100 by 100 positive semidefinite variable.
X = cp.Variable((100, 100), PSD=True)

# You can use X anywhere you would use
# a normal CVXPY variable.
obj = cp.Minimize(cp.norm(X) + cp.sum(X))

```

The second way is to create a positive semidefinite cone constraint using the >> or << operator. If X and Y are n by n variables, the constraint X >> Y means that  `z<sup>T</sup>(X-Y)z>=0` for all z $\in$ R<sup>n</sup>.
In other words, (X-Y)+ (X-Y)<sup>T</sup> s positive semidefinite. The constraint does not require that X and Y be symmetric. Both sides of a postive semidefinite cone constraint must be square matrices and affine.

The following code shows how to constrain matrix expressions to be positive or negative semidefinite (but not necessarily symmetric).

```py
# expr1 must be positive semidefinite.
constr1 = (expr1 >> 0)

# expr2 must be negative semidefinite.
constr2 = (expr2 << 0)
```

To constrain a matrix expression to be symmetric, simply write

```py
# expr must be symmetric.
constr = (expr == expr.T)

```

You can also use Variable((n, n), symmetric=True) to create an n by n variable constrained to be symmetric. The difference between specifying that a variable is symmetric via attributes and adding the constraint X == X.T is that attributes are parsed for DCP information and a symmetric variable is defined over the (lower dimensional) vector space of symmetric matrices.


# 3 Mixed-integer programs


In mixed-integer programs, certain variables are constrained to be boolean (i.e., 0 or 1) or integer valued. You can construct mixed-integer programs by creating variables with the attribute that they have only boolean or integer valued entries:

```py
# Creates a 10-vector constrained to have boolean valued entries.
x = cp.Variable(10, boolean=True)

# expr1 must be boolean valued.
constr1 = (expr1 == x)

# Creates a 5 by 7 matrix constrained to have integer valued entries.
Z = cp.Variable((5, 7), integer=True)

# expr2 must be integer valued.
constr2 = (expr2 == Z)

```

CVXPY provides interfaces to many mixed-integer solvers, including open source and commercial solvers. For licensing reasons, CVXPY does not install any of the preferred solvers by default.

The preferred open source mixed-integer solvers in CVXPY are [GLPK_MI](https://www.cvxpy.org/tutorial/constraints/index.html#id2), [CBC](https://www.cvxpy.org/tutorial/constraints/index.html#id4) and [SCIP](https://www.cvxpy.org/tutorial/constraints/index.html#id6). The CVXOPT_ python package provides CVXPY with access to GLPK_MI; CVXOPT can be installed by running `pip install cvxopt` in your command line or terminal. SCIP supports nonlinear models, but GLPK_MI and CBC do not.

CVXPY comes with ECOS_BB – an open source mixed-integer nonlinear solver – by default. However ECOS_BB will not be called automatically; you must explicitly call `prob.solve(solver='ECOS_BB')` if you want to use it ([changed in CVXPY 1.1.6](https://www.cvxpy.org/updates/index.html#changes116)). This policy stems from the fact that there are recurring correctness issues with ECOS_BB. If you rely on this solver for some application then you need to be aware of the increased risks that come with using it. If you need to use an open-source mixed-integer nonlinear solver from CVXPY, then we recommend you install SCIP.

If you need to solve a large mixed-integer problem quickly, or if you have a nonlinear mixed-integer model that is challenging for SCIP, then you will need to use a commercial solver such as CPLEX_, GUROBI_, XPRESS_, MOSEK_, or COPT_. Commercial solvers require licenses to run. CPLEX, GUROBI, and MOSEK provide free licenses to those in academia (both students and faculty), as well as trial versions to those outside academia. CPLEX Free Edition is available at no cost regardless of academic status, however it still requires online registration, and it’s limited to problems with at most 1000 variables and 1000 constraints. XPRESS has a free community edition which does not require registration, however it is limited to problems where the sum of variables count and constraint count does not exceed 5000. COPT also has a free community edition that is limited to problems with at most 2000 variables and 2000 constraints.

>**Note:**
If you develop an open-source mixed-integer solver with a permissive license such as Apache 2.0, and you’re interested in incorporating your solver into CVXPY’s default installation, please reach out to us at our GitHub issues. We are particularly interested in incorporating a simple mixed-integer SOCP solver.

# 4 Complex valued expressions

By default variables and parameters are real valued. Complex valued variables and parameters can be created by setting the attribute complex=True. Similarly, purely imaginary variables and parameters can be created by setting the attributes imag=True. Expressions containing complex variables, parameters, or constants may be complex valued. The functions `is_real`, `is_complex`, and `is_imag` return whether an expression is purely real, complex, or purely imaginary, respectively.

>imaginary variables 虚拟变量

```py
# A complex valued variable.
x = cp.Variable(complex=True)
# A purely imaginary parameter.
p = cp.Parameter(imag=True)

print("p.is_imag() = ", p.is_imag())
print("(x + 2).is_real() = ", (x + 2).is_real())

```

```
p.is_imag() = True
(x + 2).is_real() = False
```

The top-level expressions in the problem objective must be real valued, but subexpressions may be complex. Arithmetic and all linear atoms are defined for complex expressions. The nonlinear atoms abs and all norms except norm(X, p) for p < 1 are also defined for complex expressions. All atoms whose domain is symmetric matrices are defined for Hermitian matrices. Similarly, the atoms quad_form(x, P) and matrix_frac(x, P) are defined for complex x and Hermitian P. All constraints are defined for complex expressions.

The following additional atoms are provided for working with complex expressions:

+ real(expr) gives the real part of expr.

+ imag(expr) gives the imaginary part of expr (i.e., expr = real(expr) + 1j*imag(expr)).

+ conj(expr) gives the complex conjugate of expr.

+ expr.H gives the Hermitian (conjugate) transpose of expr.