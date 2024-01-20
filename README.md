# EEG Interictal Spike Detection

***This code is for research purposes only.***

This EEG Spike Detection code allows the detection of interictal spikes in an electroencephalogram (EEG) recording by using a fully automated method described in [Nonclercq2012] and [Nonclercq2009]. It is fully automated and adapts to interpatient and intrapatient variation in spike morphology.

NB. A version of the algorithm that is compatible with Statistical Parametric Mapping (SPM) software is available at https://www.fil.ion.ucl.ac.uk/spm/ext/.  

## Algorithm
The algorithm works in five steps:
1.	Spikes are detected using parameters suitable for highly sensitive detection.
2.	Detected spikes are separated into clusters.
3.	The number of clusters is automatically adjusted.
4.	Centroids are used as templates for more specific spike detections, therefore adapting to the types of spike morphology.
5.	Detected spikes are summed.
Detected spikes are marked as spike events with a value corresponding to the electrode name where the spike has been detected.

### Statistics
At the end of the detection process, the algorithm computes and exports in an Excel file various statistics [VanHecke2022]:
1.	the spike-wave index (SWI), corresponding to the percentage of spike-and-wave (SW) activity, calculated by dividing the number of seconds demonstrating one or more SW by the length of the extract, multiplied by 100 to express the results as percentages,
2.	the spike-wave frequency (SWF) corresponding to the number of SW events in the first 100 s of the EEG (0 if the duration of the analysis is less than 100 s), and finally,
3.	the Generalized SWI (SWIG), that is, the SWI restricted only to SW that spread to >80% of the electrodes.

## Dependencies
The following Matlab toolboxes are required:
- Parallel Computing Toolbox
- Signal Processing Toolbox 
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox

Matlab R2023a was used to develop the algorithm.

## Licence
If you use this toolbox for a publication (in a journal, at a conference, etc.), please cite both related publications: [Nonclercq2012] and [Nonclercq2009]. 

As SPM, the license attached to this toolbox is GPL v2, see https://www.gnu.org/licenses/gpl-2.0.txt. 
From https://www.gnu.org/licenses/gpl-2.0.html, it implies: *This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; 
either version 2 of the License, or (at your option) any later version.*

## References
**[Nonclercq2009]** Nonclercq, A., Foulon, M., Verheulpen, D., De Cock, C., Buzatu, M., Mathys, P., & Van Bogaert, P. (2009). Spike detection algorithm automatically adapted to individual patients applied to spike and wave percentage quantification. 
Neurophysiologie Clinique, 39, 123–131. doi:10.1016/j.neucli.2008.12.001    
**[Nonclercq2012]** Nonclercq, A., Foulon, M., Verheulpen, D., De Cock, C., Buzatu, M., Mathys, P., & Van Bogaert, P. (2012). Cluster-based spike detection algorithm adapts to interpatient and intrapatient variation in spike morphology. 
Journal of Neuroscience Methods, 210(2), 259–265. doi:10.1016/j.jneumeth.2012.07.015  
**[VanHecke2022]** Van Hecke A, Nebbioso A, Santalucia R, Vermeiren J, De Tiège X, Nonclercq A, Van Bogaert P, Aeby A. The EEG score is diagnostic of continuous spike and waves during sleep (CSWS) syndrome. 
Clin Neurophysiol. 2022 Jun;138:132-133. doi: 10.1016/j.clinph.2022.03.013. Epub 2022 Mar 25.PMID: 35390761.

