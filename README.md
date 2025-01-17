# humanclock

The detailed model consists of 180 variables and 70 parameters.
 
Step 1: Fixing Variables
We fixed the output variable (Output (21) = MnB_dot) and analyzed the bifurcation types associated with individual parameters and various parameter sets. To simulate the effects of temperature changes, the factorlist value was reduced from 1 (high temperature) to 0 (low temperature), representing proportional changes in parameter values corresponding to decreasing temperatures.
 
Simulation 1: Single-Parameter Analysis (Figure 4A)
1.	Transcription Rate for Bmal1 (trB)
Parameter: parameterValueNew(5)
Observations: As the factorlist value decreased, the amplitude of oscillations gradually reduced to zero, while the period remained relatively constant.
Conclusion: These results indicate the occurrence of Hopf bifurcation for the transcription rate of Bmal1.
2.	Transcription Rate for Per1 (trPo)
Parameter: parameterValueNew(1)
Observations: Both the amplitude and period remained relatively constant as the factorlist value decreased.
Conclusion: These results indicate that no bifurcation occurs for the transcription rate of Per1.
 
Simulation 2: Multiple-Parameter Analysis (Figure 4A)
Three parameters were analyzed simultaneously to determine their combined impact:
1.	Parameter No. 63: Degradation rate of Bmal1.
2.	Parameter No. 30: Unbinding rate of Rev-erb from NPAS2.
3.	Parameter No. 19: Unbinding rate of PER from CRY. 
Observations: As the factorlist value decreased, the period of oscillations gradually approached infinity, while the amplitude remained relatively constant.
Conclusion: These results indicate the occurrence of SNIC bifurcation for this specific parameter set.
The interactions among these parameters were analyzed, providing insights into their contributions to the bifurcation dynamics of the circadian system.
 
Categorizing Bifurcations
By systematically analyzing the probabilities of Hopf and SNIC bifurcations:
Hopf bifurcation: The probability was positively correlated with the number of parameters.
SNIC bifurcation: The likelihood of SNIC bifurcation exist small occurence.
These findings suggest that Hopf bifurcation is the predominant mechanism in the detailed model (Figure 4B).
![image](https://github.com/user-attachments/assets/fc01c27f-3b77-4a03-9d61-253fca34b471)

