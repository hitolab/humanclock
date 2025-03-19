# humanclock

The detailed model for mammalian circadian clock consists of 180 variables and 70 parameters.

We numerically solved Kim-Forger model using  MATLAB code provided by the authors{kim2012mechanism}. To classify a type of bifuracation, we chose a variable as a representative of circadian dynamics, the concentration of Bmal1 in the nucleus. We hypothesized some of 70 parameters of this model depend on temperature $T$ , i.e., $k^\prime_i=\alpha(T)k_i$ where ki represents the value of temperature-dependentparameter and $\alpha (T) \in [0,1]$ is a tepmerature-dependent factor with 1 corresponding to high temperature and 0 to low temperature. 

Code 1: Time series Bifurcation types analysis of various parameter (Figure 4A).

1.Parameter name: Transcription Rate constant for \textit{Bmal} (trB)
   Parameter Number: parameterValueNew(5)
   Observations: As the tepmerature-dependent factor value decreased, the amplitude of oscillations gradually reduced to zero, while the 
    period remained relatively constant.
   Conclusion: These results indicate the occurrence of Hopf bifurcation for the transcription rate of Bmal1.

2.Parameter name: Transcription Rate of \textit{Per1} (trPo).
   Parameter number: parameterValueNew(1).
   Observation: Both the amplitude and period remained stable as the factor value decreased from 1 to 0.
   Conclusion: These results suggest that no bifurcation occurs for the transcription rate of \textit{Per1}.

3.Three parameters were analyzed simultaneously to determine their combined impact
   Parameter No. 63: Degradation rate of Bmal1.
   Parameter No. 30: Unbinding rate of Rev-erbs from NPAS2.
   Parameter No. 19: Unbinding rate of PER1/2 from CRY1/2. 
   Observations: As the factor value decreased, the period of oscillations gradually approached infinity, while the amplitude remained 
   relatively constant.
   Conclusion: These results indicate the occurrence of SNIC bifurcation for this specific parameter set.
 
Code 2: Factor value dependent dynamics change of various parameter analysis (Figure S3).
   
   To investigate bifurcation dynamics change with factor value decrease, we analyzed bifurcation types associated with various random parameter. The factor value was gradually reduced from 1 to 0, reflecting temperatures decreases. To identify potential Hopf or SNIC bifurcations dynamics change, we detected the impact of temperature-driven parameter changes on circadian oscillation.

Code 3: Hopf bifurcations with 70 parameters (Figure 4B).

      By systematically analyzing the probabilities of Hopf and SNIC bifurcation in the detailed model;

The Goodwin model{Gonze2020Goodwin}, incorporating a negative feedback loop, is used to classify the type of bifurcation that occurs as parameter values change.

Code 4: SNIC bifurcations with 70 parameters (Figure 4B).

Code 5: Classification of bifurcations in the Goodwin model (Figure S5).
