CREATE OR REPLACE FUNCTION column_pivoting_from_table() RETURNS double precision[][] AS $$
    import pandas as pd
    import numpy as np
    import plpy

    sql_query = "SELECT * FROM dataset"
    result = plpy.execute(sql_query)

    column_names = result[0].keys()
    data = [row.values() for row in result]
    df = pd.DataFrame(data, columns=column_names)

    df = df.apply(pd.to_numeric, errors='coerce')
    df = df.dropna()  # Drop rows with NaN values
    input_matrix = df.to_numpy(dtype=np.float64)

    def qr_factorization_gram_schmidt_pivoting(A):
        m, n = A.shape
        Q = np.zeros((m, n))
        R = np.zeros((n, n))
        P = np.eye(n)
        for k in range(n):
            max_col_index = np.argmax(np.linalg.norm(A[:, k:], axis=0))
            max_col_index += k
            A[:, [k, max_col_index]] = A[:, [max_col_index, k]]
            P[:, [k, max_col_index]] = P[:, [max_col_index, k]]
            v = A[:, k].astype(np.float64)  # Convert to float64 explicitly
            for j in range(k):
                R[j, k] = Q[:, j] @ A[:, k]
                v -= R[j, k] * Q[:, j]
            R[k, k] = np.linalg.norm(v)
            Q[:, k] = v / R[k, k]
        return R

    result = qr_factorization_gram_schmidt_pivoting(input_matrix)
    return result.tolist()
$$ LANGUAGE plpython3u;
