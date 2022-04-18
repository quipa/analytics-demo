"""MAXDM - Maxim's Species Distribution Modelling framework"""

import warnings

import numpy as np
import pandas as pd
from sklearn.base import BaseEstimator
from sklearn.compose import ColumnTransformer
from sklearn.metrics import pairwise_distances
from sklearn.preprocessing import MinMaxScaler

__author__ = 'Maxim Jaffe'


class GMS(BaseEstimator):
    """GMS - Geometric Median Similarity model
    
    Estimates species distribution based on similarity to a scaled geometric median of occurences.
    
    Parameters
    ----------
    dist: str, default='l1'
        Distance metric. See scikit-learn.
    
    Notes
    -----
    Scaled geometric median of all occurences is calculated based on scaled distance between, where each variable is min-max scaled to a [0, 1] range.
    
    Similarity is calculated as:
        1 - (scaled distance / number of variables)
        
    This model is should be similar to BIOCLIM model, but uses a geoemtric median instead of an centroid (mean).
        
    Warning
    -------
    When predicting assumes variable range is within that of the fitted model variable range.
    """
    
    _minmax_scaler = MinMaxScaler()
    
    def __init__(self, metric='l1'):
        self.metric = metric
    
    def fit(self, X, Y):
        """Fit species distribution model 
        
        Note that X and Y need to match in len
        
        Parameters
        ----------
        X: pandas.Dataframe
            Variables
        Y: pandas.Dataframe
            Occurrences
        
        """
        
        assert len(X) == len(Y)
        
        self.columns = X.columns
        
        # Fit column min-max scaler
        self.minmax_col_scaler = ColumnTransformer(
            transformers=[('mm', self._minmax_scaler , self.columns)])
        self.minmax_col_scaler.fit(X)
        
        # Scale variables
        X_scaled = self.minmax_col_scaler.transform(X)
        
        # Select rows with ocurrences
        X_occ = X_scaled[Y == 1]
        
        # Find geometric median
        X_occ_dist_matrix = pairwise_distances(X_occ, metric=self.metric)
        X_occ_dist_sum = X_occ_dist_matrix.sum(axis=0)
        
        self.geom_median = X_occ[[X_occ_dist_sum.argmin()],:]
    
    def predict(self, X):
        """Predict species distribution
        
        Parameters
        ----------
        X: pandas.Dataframe
            Variables
        
        Returns
        -------
        pandas.Dataframe
            Similarity
        """
        
        # Check data has the same variables
        assert (X.columns == self.columns).all()
        
        # Scale variables
        X_scaled = self.minmax_col_scaler.transform(X)
        
        # Check if any value is not within [0,1] range
        # TODO need to test this check
        if np.logical_or(X_scaled < 0, X_scaled > 1).any():
            warnings.warn('Some values are beyond fitted model ranges.')
        
        # Calculate distance to geometric median
        dist = pairwise_distances(
            X_scaled, self.geom_median, metric=self.metric)
        
        # Calculate similarity
        sim = 1 - (dist / len(self.columns))
        
        # Convert similarity output to dataframe while keeping input indexes
        df = pd.DataFrame(index=X.index)
        df['sim'] = sim
        
        return df
    


class KNNS(BaseEstimator):
    """KNNS - K Neareast Neighbour Similarity model
    
    Estimates species distribution based on similarity to nearest neighbour in occurences.
    
        Parameters
    ----------
    dist: str, default='l1'
        Distance metric. See scikit-learn.
    
    Notes
    -----
    Caculated based on scaled distances, where each variable is min-max scaled to a [0, 1] range.
    
    Mean scaled distance to k nearest neighbours (knn) is used to calculate similarity.
    
    Similarity is calculated as:
        1 - (mean(knn scaled distances) / number of variables)
        
    This model is should be similar to DOMAIN model when k = 1.
        
    Warning
    -------
    When predicting assumes variable range is within that of the fitted model variable range.
    """
    # TODO code repetition between GMS and NNS, maybe create mixin class?
    
    _minmax_scaler = MinMaxScaler()
    
    def __init__(self, k=1, metric='l1'):
        self.k = k
        self.metric = metric
    
    def fit(self, X, Y):
        """Fit species distribution model 
        
        Note that X and Y need to match in len
        
        Parameters
        ----------
        X: pandas.Dataframe
            Variables
        Y: pandas.Dataframe
            Occurrences
        
        """
        
        assert len(X) == len(Y)
        
        self.columns = X.columns
        
        # Fit column min-max scaler
        self.minmax_col_scaler = ColumnTransformer(
            transformers=[('mm', self._minmax_scaler , self.columns)])
        self.minmax_col_scaler.fit(X)
        
        # Scale variables
        X_scaled = self.minmax_col_scaler.transform(X)
        
        # Select rows with ocurrences
        self.occ_scaled = X_scaled[Y == 1]
    
    def predict(self, X):
        """Predict species distribution
        
        Parameters
        ----------
        X: pandas.Dataframe
            Variables
        
        Returns
        -------
        pandas.Dataframe
            Similarity
        """
        
        # Check data has the same variables
        assert (X.columns == self.columns).all()
        
        # Scale variables
        X_scaled = self.minmax_col_scaler.transform(X)
        
        # Check if any value is not within [0,1] range
        # TODO need to test this check
        if np.logical_or(X_scaled < 0, X_scaled > 1).any():
            warnings.warn('Some values are beyond fitted model ranges.')
        
        # Calculate distances to occurences
        dist = pairwise_distances(X_scaled, self.occ_scaled, metric=self.metric)
        
        # Select k nearest neighbours
        knn = np.sort(dist, axis=1)[:,:self.k]
        
        # Calculate mean of k nearest neighbours
        mean_dist = knn.mean(axis=1)
        
        # Calculate similarity
        sim = 1 - (mean_dist / len(self.columns))
        
        # Convert similarity output to dataframe while keeping input indexes
        df = pd.DataFrame(index=X.index)
        df['sim'] = sim
        
        return df
