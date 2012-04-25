
import unittest
import glob
import nose
import logging
import sys
import os


from openmdao.util.testutil import assert_raises, assert_rel_error

class OMModelWrapperTestCase(unittest.TestCase):

    def setUp(self):
        if os.name != 'nt':
            raise nose.SkipTest('Sorry, OMModelWrapper has only been validated on Windows.')
        if os.name == 'posix':
            raise nose.SkipTest('Sorry, OMModelWrapper has only been validated on Windows.')
        
    def tearDown(self):
        pass
        
    
    def test_OMModelWrapper(self):
        logging.debug('')
        logging.debug('test_OMModelWrapper')
        
        from ommodelwrapper.ommodelwrapper import OMModelWrapper
        testModel = OMModelWrapper('SimAcceleration','VehicleDesign.mo')
        testModel.stopTime = 10
        testModel.execute()  
        assert_rel_error(self, testModel.accel_time[-1],6.935,0.01)  
        del(testModel)
        os._exit(1)
            
if __name__ == "__main__":
    sys.argv.append('--cover-package=ommodelwrapper.')
    sys.argv.append('--cover-erase')
    nose.runmodule()
    