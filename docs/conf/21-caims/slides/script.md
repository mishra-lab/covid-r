
# Outline:
1. Briefly review the reproduction number
2. How do we calculate R(t)
3. Calculating the Generation Time Distribution
4. Results
5. Implications

# Reproduction Number: Defined

As many of you will probably know,
the basic reproduction number, or "R", represents
the average number of new infections originating from each current infection.
As a result, R is directly related to the rate of exponential growth of the epidemic.
And the other factor determines the timescale of that exponential growth
is the average time between infections, which we will get to know well today.

# Effective Reproduction Number

It's worth distinguishing the basic reproduction number or "R_0" from
the effective reproduction number "R(t)".
R_0 is more-or-less an inherent property of an infectious disease,
at least under so-called "normal" conditions
and in an entirely susceptible population.

In a classic epidemic modelling framework, R_0 can be defined as the product of:
beta - the probability of transmission per contact,
C - the rate of contact formation, and
D - the duration of infectiousness.

By contrast, the effective reproduction number R(t) considers epidemic conditions,
and so at minimum, includes the proportion of individuals who are still susceptible,
but potentially also changes to
probability of transmission, contact rates, or duration of infectiousness.

And at right we illustrate a case where,
starting from a basic reproduction number of 3,
if any of the components are reduced by a factor of 2/3,
then the effective reproduction number becomes 2.

# R_0 of Common Diseases

The basic reproduction number of some common diseases include
measles at over 12, polio at about 6, seasonal flu about 2,
and of course COVID-19 around 2.5, at least for the original variant.
However, again, it's important to remember that these values
represent initial conditions, so before any interventions,
and subject to the social or environmental conditions of that population.

# Applications of R

Why would we want to estimate the reproduction number?
First, it represents an overall measure of epidemic potential,
or effectively how hard it will be to control an epidemic.

Second, in the case of the effective reproduction number,
it gives a rough estimate of recent intervention effectiveness,
where we are of course hoping to bring R(t) below 1.

Third, we can estimate the required vaccine coverage required
to maintain R(t) < 1 in the absence of any other interventions,
using 1 minus the reciprocal of R_0,
which can then be further adjusted for imperfect vaccine effectiveness.

# Estimating R_0: 3 Methods

So how do we estimate the reproduction number?
There are at least three methods,
and our work focuses on the second method.

# Exponential Model for R_0

The simplest model for R is derived from a standard exponential function.
In this case, I(t) is the number of new infections observed at time t,
and alpha is the exponential growth rate.
However, we also need to know the average time between subsequent infections;
this is called the generation time, "g".
Then, the expected number of new infections per current infection, or R_0,
is defined as the ratio of any two points along the infection curve I(t),
separated by a period of g,
which is equivalent to the exponentiated growth rate times g.

# Exponential Model: Assumptions

What are the assumptions of the exponential model?
First, that the population is homogeneous and fully susceptible.
Second, that R_0 is constant over the period considered.
Third, that the number of reported infections is proportional
to the number of true infections.
So it actually does not matter that only a proportion of infections are reported,
only that the proportion does not change over time,
since its the ratio of infections between two time points that we use
to calculate R_0.

It's also worth noting that the generation time G has
perhaps a counter-intuitive relationship with the estimated R_0.
If the generation time is long, then we would expect a slower exponential growth.
However, for the same exponential growth observed,
a longer generation time then means that a smaller number of cases
further back in time must be producing the same number of cases we see today,
and so the reproduction number we infer is actually larger.

# Renewal Equation for R(t)

The next method to estimate R(t) builds upon the exponential model,
but allows us to relax the assumption of a fixed generation time,
and instead consider a distribution for the generation time G(tau).
Effectively, G(t) represents the relative infectiousness of an individual
at time "t" since becoming infected.

In this case, the number of expected infections at time "t"
is then modelled as the integral over all previous infections,
each multiplied by their respective generation time distributions at time "t",
and then all multiplied by the effective reproduction number.
Then, the reproduction number can be estimated similar to before:
by rearranging the equation and dividing
the actual number of observed infections
by the integral, reflecting when additional infections are expected.

Also, if the generation time distribution eventually decays away to zero,
reflecting the fact that people are no longer infectious after a period of time,
then we really only need to integrate over a recent window at least that long.
So we can call that window "w".

# Renewal Equation Illustrated

Here is an illustration of a series of infections indexed "i",
and their respective generation time distributions.
Then, the integral is the cumulative sum over all those distributions,
shown here in blue, representing *when* infections are expected.
And the effective reproduction number is
the actual number of observed infections at time "t"
divided by the integral.

The assumptions for this approach are
essentially the same as in the exponential model,
including the assumption that the reproduction number
is constant over the analysis period.
However, since we are often interested in the time trends of R(t),
we can simply repeat the analysis with a moving window over time.

# R(t) Examples

Here are some examples from the original paper on this method,
by Anne Cori and colleagues
In the first row, we have the number of new infections over time,
and below: the estimated reproduction number R(t).
We can see that spikes in R(t) are inferred before spikes in infections,
which of course we can only infer retrospectively,
but in a real-time context, recent upticks in R(t)
can indicate that current interventions are likely not sufficient.

So, assuming that case data are reasonably reliable,
really the key input required by this model is
the distribution of infectiousness, or the generation time distribution.
This is really where our contribution is:
in estimating the distribution of infectiousness.

# Infectiousness: Serial Interval (Symptoms)

Classically, the distribution of infectiousness has been characterized using
the times of symptom onset in case pairs.
The difference in those times represents random samples from
a distribution we call the serial interval.
So, we can fit some parametric distribution to the data,
such as a gamma distribution,
and this is usually a reasonable approximation of the distribution of infectiousness.

However, the true distribution of infectiousness, the generation time distribution
reflects the time between infection events,
which may precede symptom onset by hours, days, or longer depending on the infection.
That delay from infection to symptom onset is known as the incubation period.
It's difficult to characterize the generation time distribution directly
since the exact moment of infection is often difficult to determine,
especially for both members of a transmission pair,
and for household or repeated contacts.

# Infectiousness: Serial Interval vs Generation Time

Illustrating these events and distributions,
where time moves forward top to bottom.
First, we have the serial interval for an infection pair (y_{i+1} - y_{i}),
but what we want to obtain is the generation time (f_{i+1} - f_{i}),.
The symptom onset in case "i" is delayed by the incubation period,
as it is in the next case "i+1".
So, overall, the system looks like this,
and our goal will be to recover the generation time distribution,
given that the serial interval and incubation period are known.

# Recovering the Generation Time Distribution

Based on this model, the relationships between the random variables
can be summarized like this,
which allows us to define the serial interval s_i
in terms of the genration time g_i and two incubation periods h_i and h_i+1.
Then, it can be shown that
the distribution of a sum of independent random variables
is given by the convolution of their respective distributions.
So, the serial interval distribution is therefore defined as
the convolution of the generation time distribution,
with two incubation period distributions (where one is flipped).

In fact, this flipped distribution ensures that
the mean of the serial interval and generation time distributions are equal.
But as you could imagine, the variance of the serial interval distribution
will be greater, since convolution has a blurring effect.

This then allows us to define the generation time distribution
by rearranging with the deconvolution operation
as shown here.

# Practical Deconvolution

Unfortunately, since the deconvolution task is attempting to "undo"
the blurring effect of the incubation periods,
an exact solution to the deconvolution problem can become unstable,
resulting in an improper or implausible solution for G(t),
such as negative probability values.

To overcome this challenge, we enforce a parametric form for G(t),
such as a gamma distribution or log-normal,
and then estimate the model parameters that best fit
the given serial interval distribution S,
based on the forward convolution.
Since "S" is a probability distribution,
a good measure of "fit" is the K-L Divergence between
the "known" serial interval distribution
and the serial interval distribution
predicted by the model based on forward convolution.

# Estimating G(t): Data

So, finally, we can actually estimate
the generation time distribution for COVID-19,
again, given the distributions of the serial interval and the incubation period.
For these two distributions, we took the best-fitting parametric models
from studies with large sample size last year,
with the parameterizations given here.

# COVID-19 & Pre-symptomatic Transmission

While the proposed method to infer the generation time distribution
allows us to more precisely estimate R(t) in general,
our approach is especially valuable in the case of COVID-19.
The reason is that some COVID-19 transmission is thought to be pre-symptomatic.
This then means it is possible for the second person in a transmission pair
to develop symptoms before the first person,
in which case the serial interval could actually be negative.
However, by definition, the generation time distribution is always positive.

Moreover, there is a popular R package called EpiEstim
that implements the Renewal Equation model to calculate R_e(t).
The input for the model was unfortunately termed the "serial interval",
though within the code it is used as the generation time distribution,
and notably, it is forced to be non-negative.

# Estimating R_e(t): Data

So we would also like to know how the estimated reproduction number
is potentially biased, if the serial interval distribution is used
where it really should be the generation time distribution.
The additional data we need is the incidence time series I(t),
which we obtained for the Greater Toronto Area
from Public Health Ontario through the Ontario Modelling Consensus Table.
And for illustrative purposes, we'll just focus on March and April of last year.

For the generation time, we used the distribution we inferred.
And for the serial interval, we explored several parametric forms
reported in the literature, including forms
that did allow negative values ("negative-permitting"),
and those that did not ("non-negative").

# Recovered Generation Time Distribution

Results.

The figure shows the input serial interval distribution S(t) in red
and incubation period distribution H(t) in purple,
and then the recovered generation time distribution in blue.
The dotted red line is the approximation of S(t) predicted given
the best fit generation time distribution.
We can see it fits reasonably well, and certainly better
than the approximation of the blue generation time with the red serial interval.

We can also see that a good proportion of the probability mass for G(t)
occurs in the first 2-3 days,
while the incubation period distribution H(t) in purple is still nearly zero.
Again, this is really illustrating the chance of pre-symptomatic infection.

The values of alpha and beta are also given here,
from which we can compute the mean and variance of the
Gamma distribution.
As expected, the mean is almost exactly the same
as the input serial interval distribution (around 4),
but the variance is reduced through the quasi-deconvolution operation
(from 4.75 to about 3.2).

# Generation Time vs Serial Interval Distributions

Plotting the generation time distribution (here in purple) versus
serial intervals reported in the literature.
The negative-permitting distribution from Du and colleagues
(again in red) is as I just described
since this was the input we used to estimate the generation time distribution.
But the non-negative distributions from Zhang and Nishiura
both have greater mean values than the estimated generation time distribution,
(at around 5).
If you'll recall from earlier regarding estimation of R_e(t),
if we assume longer time between infections,
then we would infer larger values of R_e(t),
and in fact that's what we see.

# COVID-19 Infections I(t) in GTA

Just for reference, here are the case data
for which we estimated R_e(t).

# R(t) using S(t) vs G(t)

And finally here is the estimated reproduction number over time for those data
calculated using the different distributions.
Assuming that the generation time distribution in purple
is the "gold standard",
we can see that using non-negative serial interval distributions
(the blue and green colours)
result in overestimation of R(t), again, due to larger mean.
Since generation time and serial interval should in fact always have the same mean,
this difference may be due to
improperly forcing the serial interval distribution to be non-negative.

By contrast, the negative-permitting distribution (in red)
tends to underestimate R(t), due to larger variance.
That relationship might seem counter-intuitive,
but if we think back to the exponential model,
greater variance in the time between infections
would allow more "early" infections,
which could themselves produce more early infections,
and thereby dominate the proportion of new infections.
So the expected rate of exponential growth would be greater.
And then, when comparing to the observed rate of exponential growth,
we would then infer fewer new infections per current infection,
which is R(t).

# Implications

What are the main implications of this work?

First, we've estimated the generation time distribution for COVID-19.
Since this distribution effectively represents
the distribution of infectiousness following exposure,
the distributional characteristics may be useful for informing guidelines,
such as to estimate the proportion of pre-symptomatic transmission,
or the relative infectiousness after 1 week or 2 weeks, etc.

Second, we have developed a new method to infer
the generation time from the serial interval and incubation period distributions.
This method may then be easily applied to other infections.
And since the inputs are parametric distributions,
there's no need to obtain individual-level transmission pair data.

Finally, we showed how approximation of the generation time distribution
with the serial interval distribution can result in biased estimates of R_e(t).
Specifically, using non-negative serial interval distributions
may result in overestimated R_e(t),
whereas negative-permitting serial distributions,
may result in underestimated R_e(t).

# Limitations

In terms of limitations,
we assumed independence of all the distributions involved,
although previous work in the context of measles
showed that this assumption may not hold.

We also used parametric distributions throughout,
which may result in compounded errors of approximation.
However, this type of input may actually be useful for meta-analyses.

And perhaps most importantly,
we did not conduct any uncertainty analysis
or estimate the confidence intervals around the parameters for G(t),
which could then be propagated through to estimates of R(t)
through sampling some sort of hierarchical model.

# Thanks & Questions


