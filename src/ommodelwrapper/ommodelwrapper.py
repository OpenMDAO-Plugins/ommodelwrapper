__all__ = ['OMModelWrapper']

from openmdao.main.api import Component
from openmdao.lib.datatypes.api import Float, Str, Array
from xml.etree import ElementTree as ET

import sys
import os
import numpy as np
import load_modelica_mat as lmm
import OM_build
import subprocess

# Make sure that your class has some kind of docstring. Otherwise
# the descriptions for your variables won't show up in the
# source ducumentation.
class OMModelWrapper(Component):
    """
    This is a wrapper of an OpenModelica model. It compiles OpenModelica's .mo
    file and builds its .exe executable to be used in OpenMDAO.
    
    By default, the wrapper initiation reads through the model parameter and 
    variable entries and their default values, and creates the inputs 
    and outputs of the wrapper component, correspondingly.
    
    OMModelWrapper(moFile[, pkgName]) -> new Python wrapper of OpenModelica model    
        moFile          : main model file name in String. '.mo' is not included 
        pkgName         : additional .mo file or library name in String 
                          ('.mo' must be included if there is in the name)
                          More than one package is not supported yet.
        
        
    startTime
        Simulation start time (float)
    
    stopTime
        Simulation stop time (float)
    
    stepSize
        Time step on which simulation data are recorded as result (float)
        
    tolerance
        Simulation solver accuracy (float)
        
    solver
        Name of the chosen solver, which OpenModelica supports (string) 
        
    execute(...)
        Execute the model and update the output
        
    Additional attributes will be accessible based on the parameter/variable
    definitions of the original OpenModelica to be wrapped.    
    """
    def __init__(self, moFile, pkgName=None):
        super(OMModelWrapper,self).__init__()

        self.moFile = moFile
        self._init_xml = moFile + "_init.xml"
        self._prm_attrib = []
        self._var_attrib = []
        self._wdir = os.getcwd()

        OM_build.build_modelica_model(usr_dir=self._wdir,fname=self.moFile, additionalLibs = pkgName)
        try:
            etree = lmm.get_etree(self._init_xml)
        except:
            sys.exit("FMI xml file incorrect or not exist")

        # Get the simulation settings
        sim_set = etree.find("DefaultExperiment").attrib
        self.add('startTime', Float(float(sim_set['startTime']),
                          iotype ='in',
                          desc   ='startTime',
                          units  ='s'))
        self.add('stopTime', Float(float(sim_set['stopTime']),
                          iotype ='in',
                          desc   ='stopTime',
                          units  ='s'))
        self.add('stepSize', Float(float(sim_set['stepSize']),
                          iotype ='in',
                          desc   ='stepSize',
                          units  ='s'))
        self.add('tolerance', Float(float(sim_set['tolerance']),
                          iotype ='in',
                          desc   ='tolerance'))
        self.add('solver', Str(sim_set['solver'],
                          iotype ='in',
                          desc   ='solver'))
        # Model param inputs
        varElem = etree.find("ModelVariables").getchildren()
        file_name = self.moFile+".mo"
        for var in varElem:
            if (file_name in var.attrib['fileName']) and\
               var.attrib['variability']=="parameter":
                print ' ', var.attrib['name']
                kwargs = {'iotype':'in', 'desc':var.attrib['name']}
                if var.find('Real') is not None:
                    value = float(var.find('Real').attrib['start'])
                    self.add(var.attrib['name'],Float(value,**kwargs))
                elif var.find('Integer') is not None:
                    value = int(var.find('Integer').attrib['start'])
                    self.add(var.attrib['name'],Int(value,**kwargs))
                elif var.find('Boolean') is not None:
                    if var.find('Boolean').attrib['start']=="0.0": value = 0
                    else: value = 1
                    kwargs['desc'] = kwargs['desc']+', boolean'
                    self.add(var.attrib['name'], Int(value,**kwargs))
                self._prm_attrib += [var.attrib['name']]


        # Next, outputs are found. Any variables except "parameters" in the
        # model file becomes output.
        for var in varElem:
            if (file_name in var.attrib['fileName']) and\
               var.attrib['variability'] != "parameter":
                print ' ', var.attrib['name']
                kwargs = {'iotype':'out', 'desc':var.attrib['name']}
                if var.find('Real') is not None:
                    kwargs['dtype'] = np.float
                elif var.find('Integer') is not None:
                    kwargs['dtype'] = np.int
                elif var.find('Boolean') is not None:
                    kwargs['dtype'] = np.bool
                    kwargs['desc'] = kwargs['desc']+', boolean'
                    self.add(var.attrib['name'], Int(value,**kwargs))
                self.add(var.attrib['name'],Array(np.array([]),**kwargs))
                self._var_attrib += [var.attrib['name']]
        self.time = Array(np.array([]),dtype=np.float,iotype='out',desc='time',units='s')
        self._var_attrib += ['time']

    def execute(self):
        """ 
        The .exe executable is run to obtain the simulation result of the
        OpenModelica model.
        """
        etree = lmm.get_etree(self._init_xml)

        # Update the sim settings to the element tree
        lmm.change_experiment(etree,startTime = self.startTime,
                                    stopTime = self.stopTime,
                                    stepSize = str(self.stepSize),
                                    tolerance = str(self.tolerance),
                                    solver = self.solver)
        # Update the parameters to the element tree
        prm_dict = {}
        for prm_name in self._prm_attrib:
            prm_dict[prm_name] = eval("self."+prm_name)
        lmm.change_parameter(etree, prm_dict)

        # Rebuild _init.xml with the updated element tree
        etree.write(self._init_xml)
        subprocess.call([self.moFile+'.exe'],shell=True)

        # Obtain the result from the result (.mat) file
        dd,desc = lmm.load_mat(self.moFile+'_res.mat')
        for var_name in self._var_attrib:
            vars(self)[var_name] = dd[var_name]

def main():
    testModel = OMModelWrapper('SimAcceleration','VehicleDesign.mo')
    testModel.stopTime = 10

    testModel.execute()
    for i in xrange(testModel.time.size):
        print testModel.time[i], testModel.accel_time[i]

if __name__ == '__main__':
    main()

