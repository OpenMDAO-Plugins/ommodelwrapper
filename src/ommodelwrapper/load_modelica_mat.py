from scipy.io import loadmat

import numpy as np


from xml.etree import ElementTree

def load_mat(datafile, expand_param_data=True):
    data = loadmat(datafile, matlab_compatible=True)
    
    names = data['name'].transpose()
    descrips = data['description'].transpose()
    
    data_loc = data['dataInfo'][0]
    data_sign = np.sign(data['dataInfo'][1])
    data_col = np.abs(data['dataInfo'][1]) - 1
    
    num_time_pts = data['data_2'][0].shape[0]
    
    data_dict = {}
    desc_dict = {}
    
    for i in xrange(names.shape[0]):
        
        name = ''.join([str(e) for e in names[i]]).rstrip()
        
        if name == 'Time':
            name = 'time'
        
        descrip = ''.join([str(e) for e in descrips[i]]).rstrip()
        
        desc_dict[name] = descrip
        
        if data_loc[i] == 1:
            if expand_param_data:
                data_dict[name] = (np.ones(num_time_pts) * 
                                   data['data_1'][data_col[i]][0] * data_sign[i])
            else:
                data_dict[name] = data['data_1'][data_col[i]] * data_sign[i]
        else:
            data_dict[name] = data['data_2'][data_col[i]] * data_sign[i]
    
    return data_dict, desc_dict


def change_attrib(elem, name, value):
    """
    Change an attribute and return True only if new value differs from old.  
    Otherwise don't change and return False.
    """
    value_type = type(value)
    if value_type(elem.attrib[name]) == value:
        print '{0} in {1} already equal to {2}'.format(name, 
                                                      str(elem), 
                                                      value)
        return False
    else:
        print 'Changed {0} in {1} from {2} to {3}'.format(name, 
                                                          str(elem), 
                                                          elem.attrib[name], 
                                                          value) 
        elem.attrib[name] = str(value)
        return True
        
        
def get_value_elem(elem, var_type):
    """
    Search for and return either a Real, Integer, Boolean or String etree 
    element based on the Python type that is intended to be assigned (float, 
    int, bool or str).  Returns None if nothing is found that matches.
    """
    if var_type is float or var_type is np.float64:
        val_elem = elem.find('Real')
        
    elif var_type is int:  
        val_elem = elem.find('Integer')
        ## Allow for assigning an int to a Real
        if val_elem is None:
            val_elem = elem.find('Real')
        
    elif var_type is bool:  
        val_elem = elem.find('Boolean')
        
    elif var_type is str:  
        val_elem = elem.find('String')
        
    else:
        raise ValueError('Unrecognized Python type = {0}'.format(var_type))
        
        
    return val_elem
    
    
def change_experiment(etree, startTime='', stopTime='', 
                      stepSize='', tolerance='', solver='', 
                      outputFormat='', variableFilter=''):
    """
    Change the default experiment values in a *_init.xml OM input file.
    
    The file should already have been parsed to an etree.
    """
    changed = False
    
    e_root = etree.getroot()
    
    e_experiment = e_root.find('DefaultExperiment')

    if startTime != '': 
        if change_attrib(e_experiment, 'startTime', startTime):
            changed = True
        
    if stopTime != '': 
        if change_attrib(e_experiment, 'stopTime', stopTime):
            changed = True
        
    if stepSize != '': 
        if change_attrib(e_experiment, 'stepSize', stepSize):
            changed = True
        
    if tolerance != '': 
        if change_attrib(e_experiment, 'tolerance', tolerance):
            changed = True
        
    if solver != '': 
        if change_attrib(e_experiment, 'solver', solver):
            changed = True
        
    if outputFormat != '': 
        if change_attrib(e_experiment, 'outputFormat', outputFormat):
            changed = True
        
    if variableFilter != '': 
        if change_attrib(e_experiment, 'variableFilter', variableFilter):
            changed = True
    
    return changed
  
  
  
def change_parameter(etree, change_dict):
    """
    Find parameters in the *_init.xml OM input file that match the keys in 
    change_dict and change them to the value in change_dict.
    
    The file should already have been parsed to an etree.
    """
    
    changed = False
    
    ## Make a set copy so that any parameters not found can be reported 
    change_set = set(change_dict)
    if len(change_set) == 0:
        return changed
        
    ## Make a dictionary to store any attempts to change non parameter variables    
    not_params = {}
        
    ## All the variables, including parameters, are in element 'ModelVariables'
    e_root = etree.getroot()
    e_variables = e_root.find('ModelVariables')
    for var in e_variables.getchildren():
        ## All the variable elements are just called <ScalarVariable> so we 
        ## need to extract the name from the attributes
        var_name = var.attrib['name']
        if var_name in change_set:
            ## Check it is actually a parameter before changing it
            if var.attrib['variability'] != 'parameter':
                not_params[var_name] = var.attrib['variability']
            else:
                ## Get the value element (Real, Integer or Boolean)
                change_val = change_dict[var_name]
                change_type = type(change_val)
                var_elem = get_value_elem(var, change_type)
                if var_elem == None:
                    raise ValueError('Did not find Real, Integer or Boolean')
                
                current_val = change_type(var_elem.attrib['start'])
                
                if current_val == change_val:
                    print 'parameter {0} is already equal to {1}'.format(
                        var_name,
                        current_val
                    )
                else:
                    ## Print the change details and do it
                    print 'changing parameter {0} from {1} to {2}'.format(
                        var_name,
                        current_val, 
                        str(change_dict[var_name])
                    )                  
                    var_elem.attrib['start'] = str(change_dict[var_name])
                    changed = True
            ## Remove a found variable from the input set copy
            change_set.remove(var_name)
            

    if len(change_set) != 0:
        print 'Could not find the following parameter variables:'
        for var in change_set:
            print '{0}, tried to set to {1}'.format(var, change_dict[var])

    if len(not_params) != 0:
        print 'The following variables are not parameters:'
        for var in not_params:
            print '{0}, variability is {1}'.format(var, not_params[var])


    return changed

def get_etree(inputfile):
    return ElementTree.parse(inputfile)
    
if __name__ == '__main__':    
    
    import matplotlib.pyplot as plt

    import subprocess
    
                
    ## Load in and parse input file     
    inputfile = 'Friction_init.xml'      
    etree = get_etree(inputfile)    
    ## Make changes to the default experiment (start, stop times etc.)
    check_exp_change = change_experiment(etree, stopTime=5.4, stepSize=0.1)

    ## Change parameter values
    check_par_change = change_parameter(etree, {'stop1.m': 1.1, 'monkey': 42, 'stop1.free': False})

    ## Write out the modified input file if anything changed
    if check_exp_change or check_par_change:
        print 'writing new XML file: {0}'.format(inputfile)
        etree.write(inputfile)
    else:
        print 'XML file: {0} does not need changing'.format(inputfile)


    ## Run executable
    cmd = ['Friction.exe']
    subprocess.call(cmd, shell=True)  



    dd, desc = load_mat('Friction_res.mat')



    plt.plot(dd['time'], dd['stop1.f'])
    plt.plot(dd['time'], dd['stop1.smax'])

    plt.xlabel(desc['time'])
    plt.ylabel(desc['stop1.f'])
    plt.ylim(-26.0, 26.0)

    plt.show()


