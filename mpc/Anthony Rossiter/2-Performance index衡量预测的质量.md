
[toc]

# What is the performance index used for?


In order to automate a predictive control strategy, that is to decide which input trajectory is best, one needs a precise numeric definition of ‘best’.
The performance index is a **numeric definition for best**.

>REMARK: Viewers make like to note that there is still an inherent contradiction in that the performance index is still to some extent arbitrary as it is rarely possible to link this to real economics.


# How should the performance index be designed?

General guidance suggests that simpler definitions are better as they lead to better conditioned and simpler optimisations.
As the optimisation is carried out online, with corresponding risks, this should only have increased complexity where the benefits are clear.

>REMARK: Typically quadratic performance indices are used as these give well conditioned optimisations with a unique minimum and generally smooth behaviours.

1-norm and inf-norm for example often result in non-smooth behaviours and can be highly sensitive.


# How many degrees of freedom?
>这里的dof是指预测的步数？

Degrees of freedom describes the complexity of the input predictions.
Consequently this issue is closely linked to the previous discussion on performance indices.
There is no point utilising high numbers of degrees of freedom in conjunction with a highly demanding performance index, if the model is poor.
The result of any corresponding optimisation would be largely meaningless, just as it would be to ask a beginner in racquet sports to construct and play an elaborate 5-10 shot rally!
