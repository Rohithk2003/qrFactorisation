CREATE OR REPLACE FUNCTION qr_decomposition(mat double precision[][])
RETURNS double precision[][]
LANGUAGE plpythonu
AS $$
import numpy as np
A = np.array(four.csv)
Q, R = np.linalg.qr(A)
result = Q.tolist(), R.tolist()
return result
$$;
