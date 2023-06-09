# AUTOGENERATED! DO NOT EDIT! File to edit: ../nbs/00_Clean.ipynb.

# %% auto 0
__all__ = ['dict_legend', 'df_pheno', 'dict_columns', 'impute_vars', 'legend', 'sum_HLA', 'clean']

# %% ../nbs/00_Clean.ipynb 3
import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# For Imputation and testing
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import SimpleImputer, KNNImputer, IterativeImputer
from sklearn.model_selection import GridSearchCV
from sklearn.preprocessing import LabelEncoder
from scipy.stats import ttest_ind, chi2_contingency

# %% ../nbs/00_Clean.ipynb 8
def legend():
    ''' 
    This returns a dictionary of the meanings of many value present in the dataset.
    '''
    # import all legend sheets
    pheno_path = 'data/interim/phenotypes/'
    file = 'Legend_Oct2012_PhenoDataset_CreatinineDataNumbers_2017_04_18.xlsx'
    df_legend1 = pd.read_excel(pheno_path + file, sheet_name=1)
    df_legend2 = pd.read_excel(pheno_path + file, sheet_name=2)

    # Setting column values
    df_legend1.columns = df_legend2.columns = ['Value', 'Description']

    # Combining legends together
    df_legend = pd.concat([df_legend1, df_legend2])

    # Creating dictionary
    dict_legend = dict(zip(df_legend.Value, df_legend.Description))
    
    return dict_legend

# %% ../nbs/00_Clean.ipynb 10
dict_legend = legend()

# %% ../nbs/00_Clean.ipynb 14
df_pheno = pd.read_csv('data/interim/phenotypes/full_pheno.csv')

# %% ../nbs/00_Clean.ipynb 31
def sum_HLA(x # HLAMismatches value ie. 110.0
           ):
    '''
    This is a helper function to transform HLAMismatches into a total sum.
    '''
    # Checking for both None type and np.nan
    # Order is import for conditional because np.nan(None) returns an error
    if x is None or np.isnan(x):
        return np.nan
    else:
        # Convert to string so there are only 3 numbers then split 
        # 120.0 -> 120 -> ['1','2','0']
        split = list(str(int(x)))
        
        # Convert to int and sum the mismatches
        mismatches = sum([int(x) for x in split])
        return mismatches


# %% ../nbs/00_Clean.ipynb 33
def clean(df_pheno:pd.DataFrame # Dataframe to be cleaned
         ):
    '''
    This function returns a cleaned full phenotype dataset and dictionary mapping for new and old columns.
    
    df_pheno is the only parameter.
    
    The cleaning steps involve:
      - Dropping duplicate columns, Removing single value columns, post transplant columns, and not useful columns
      - Creating a dictionary mapping from the old to new columns called `dict_columns`
      - Dropping rows with null eGFR1Year, eGFR5Year, RecPC1 and DonPC1 values
      - Converting all date columns to DateTime
      - Converting appropriate columns to Categorical 
      - Transforming HLAMismatches to a sum of mismatches, current it is a 3 digit indicator ie. 110.0 = 2 mismatches
      
    A visual sanity check is performed to show all the value have been converted effectively
    '''

    # Drop columns that are duplicate or have only one unique value
    df_pheno.drop([
        'RAGE', 'DAGE', 'RSEX', 'DSEX', 'SERUM_12', 'SERUM_60', # Duplicate columns
        'R_GT', 'D_GT', 'G_SURV', 'G_CENS', 'P_SURV', 'P_CENS', # single value columns
        'FAILDATE', 'COGF', 'RECIP_CT', 'RETHNIC', # low count and not useful
        'delta_eGFR', 'NEXT_TX', # not useful
        
        # Redundent Priciple Components
        'REC_PC4', 'REC_PC5', 'REC_PC6', 'REC_PC7', 'REC_PC8', 'REC_PC9', 'REC_PC10', 
        'DON_PC4', 'DON_PC5', 'DON_PC6', 'DON_PC7', 'DON_PC8', 'DON_PC9', 'DON_PC10',
        
        # Post Transplant Variable
        'AR_3M', 'AR_12M', 'DON_COD', 'RCOD', 'RDOD', 'DOD',
        'serum3', 'serum12', 'serum24', 'serum36', 'serum48', 'serum60', 'serumfinal',
        'scdate3', 'scdate12', 'scdate24', 'scdate36', 'scdate48', 'scdate60',
        'A_0', 'ALI_0', 'C_0', 'M_0', 'O_0', 'OKI_0', 'P_0', 'T_0',
        'A_3', 'C_3', 'S_3', 'O_3', 'P_3', 'M_3', 'T_3',
        'A_12', 'C_12', 'S_12', 'O_12', 'P_12', 'M_12', 'T_12',
        
        # HLA mismatch (covered in HLA mismatches)
        'R_HLA_FIRST_A_broad', 'R_HLA_FIRST_A_split', 'R_HLA_SECOND_A_broad', 'R_HLA_SECOND_A_split', 
        'R_HLA_FIRST_B_broad', 'R_HLA_FIRST_B_split', 'R_HLA_SECOND_B_broad', 'R_HLA_SECOND_B_split', 
        'R_HLA_FIRST_C_broad', 'R_HLA_FIRST_C_split', 'R_HLA_SECOND_C_broad', 'R_HLA_SECOND_C_SPLT',
        'R_HLA_FIRST_DR_broad', 'R_HLA_FIRST_DR_split', 'R_HLA_SECOND_DR_broad', 'R_HLA_SECOND_DR_split', 
        'R_HLA_FIRST_DQ_broad', 'R_HLA_FIRST_DQ_split', 'R_HLA_SECOND_DQ_broad', 'R_HLA_SECOND_DQ_split', 

        'D_HLA_FIRST_A_broad', 'D_HLA_FIRST_A_split', 'D_HLA_SECOND_A_broad', 'D_HLA_SECOND_A_split',
        'D_HLA_FIRST_B_broad', 'D_HLA_FIRST_B_split', 'D_HLA_SECOND_B_broad', 'D_HLA_SECOND_B_split', 
        'D_HLA_FIRST_C_broad', 'D_HLA_FIRST_C_split', 'D_HLA_SECOND_C_broad', 'D_HLA_SECOND_C_SPLT', 
        'D_HLA_FIRST_DR_broad', 'D_HLA_FIRST_DR_split', 'D_HLA_SECOND_DR_broad', 'D_HLA_SECOND_DR_split', 
        'D_HLA_FIRST_DQ_broad', 'D_HLA_FIRST_DQ_split', 'D_HLA_SECOND_DQ_broad', 'D_HLA_SECOND_DQ_split'
    ], inplace=True, axis=1)
    
    old_columns = df_pheno.columns
    new_columns = [
        'RecId', 'DonId', 'GraftSurvivalDays', 'GraftCensored', 
        'RecAge', 'DonAge', 'RecSex', 'DonSex', 
        'GraftNo', 'PrimaryRenalDisease', 'HasDiabetes', 
        'eGFR1Year', 'eGFR5Year', 
        'RecPC1', 'RecPC2', 'RecPC3', 'DonPC1', 'DonPC2', 'DonPC3',
        'RecHypertensionPRS', 'DonHypertensionPRS', 'RecAlbuminuriaPRS', 'DonAlbuminuriaPRS', 
        'ReceGFRPRS', 'DoneGFRPRS', 'ReceGFRDeltaPRS', 'DoneGFRDeltaPRS', 'RecStrokePRS', 'DonStrokePRS', 
        'RecIAPRS', 'DonIAPRS', 'RecHAKVPRS', 'DonHAKVPRS', 'RecPKDPRS', 'DonPKDPRS', 'RecKVPRS', 'DonKVPRS', 
        'GraftDate', 'GraftType', 'OnDialysis', 'IntracranialHaemorrhage', # was Parenchymal Intracranial Haemorrhage
        'DonType', 'HLAMismatches', 'ColdIschemiaTime', 
    ]

    # Creating a mapping dictionary
    dict_columns = dict(zip(new_columns, old_columns))

    # Rename columns
    df_pheno.columns = new_columns

    # Drop rows that have no eGFR 1 year and eGFR 5 year value
    df_pheno.dropna(subset=['eGFR1Year', 'eGFR5Year'], how='all', inplace=True)
    
    # Drop rows that are not phenotyped (RecPC1, DonPC1)
    df_pheno.dropna(subset=['RecPC1', 'DonPC1'], how='any', inplace=True)
    
    # Convert GraftDate to datetime
    df_pheno['GraftDate'] = pd.to_datetime(df_pheno['GraftDate'], format='%d/%m/%Y')

    df_pheno['GraftCensored'] = df_pheno.GraftCensored.replace({1:0, 2:1})

    df_pheno['RecSex'] = pd.Categorical(
        df_pheno.RecSex.replace({1:'Male', 2:'Female'}),
        categories=['Male', 'Female']
    )

    df_pheno['RecSex_num'] = df_pheno.RecSex.cat.codes

    df_pheno['DonSex'] = pd.Categorical(
        df_pheno.DonSex.replace({1:'Male', 2:'Female'}),
        categories=['Male', 'Female']
    )

    df_pheno['DonSex_num'] = df_pheno.DonSex.cat.codes

    df_pheno['PrimaryRenalDisease_num'] = pd.Categorical(
        df_pheno.PrimaryRenalDisease,
        categories = [
            224., 212., 241., 282., 272., 251., 252., 298., 243., 288., 285., 281., 220., 254., 271., 216., 
            273., 219., 286., 214., 283., 222., 295., 289., 229., 233., 284., 280., 250., 270., 221., 210.,
            263., 225., 211., 287., 231., 240., 223., 290., 230., 260., 293.,
            215., 200., 242., 274., 213., 259., 217., 239., 296., 292., 279.
        ]
    )     

    df_pheno['PrimaryRenalDisease'] = pd.Categorical(
        df_pheno.PrimaryRenalDisease.map(dict_legend),
        categories = [
            'Pyelonephritis/Interstitial nephritis due to V-U reflux without obstruction',
            'IgA nephropathy', 'Polycystic kidneys, adult type (dominant type)',
            'Myelomatosis/Light chain deposit disease', 'Renal vascular disease - hypertension',
            'Hereditary nephritis with nerve deafness (Alports syndrome)', 'Cystinosis', 'Other',
            'Medullary cystic disease, including nephronophthisis', 'Haemolytic Uraemic Syndrome (inc Moschowitz Syndrome)',
            'Henoch-Schonlein purpura', 'Diabetes - non-insulin dependent (Type II)',
            'Pyelonephritis/Interstitial nephritis - cause not specified', "Fabry's disease", 
            'Renal vascular disease - malignant hypertension', 'Rapidly progressive GN without systemic disease',
            'Renal vascular disease - polyarteritis', 'Glomerulonephritis, histologically examined',
            "Goodpasture's Syndrome", 'Membranous nephropathy', 'Amyloid', 
            'Pyelonephritis/Interstitial nephritis due to con obs uropathy with/without V-U reflux', 'Kidney tumour', 
            'Multi-system disease - other', 'Pyelonephritis/Interstitial nephritis due to other cause', 
            'Nephropathy due to cyclosporin A', 'Lupus erythematosus', 'Diabetes - insulin dependent (Type I)', 
            'Hereditary/Familial nephropathy - type unspecified', 'Renal vascular disease - type unspecified',
            'Pyelonephritis/Interstitial nephritis associated with neurogenic bladder',
            'Glomerulonephritis, histologically not examined', 'Congenital renal dysplasia with or without urinary tract malformation',
            'Pyelonephritis/Interstitial nephritis due to urolithiasis', 'Severe nephrotic syndrome with focal sclerosis',
            'Systemic sclerosis (Scleroderma)', 'Nephropathy due to analgesic drugs', 'Cystic kidney disease - type unspecified',
            'Pyelonephritis/Interstitial nephritis due to acquired obstructive uropathy',
            'Recipient died, graft was functioning at time of death', 'Tubulo Interstitial Nephritis (Not Pyelonephritis)', 
            'Congenital renal hypoplasia - type unspecified', 'Nephrocalcinosis & hypercalcaemic nephropathy', 
            'Membrano - proliferative glomerulonephritis', 'Polycystic kidneys, infantile (recessive type)',
            "Wegener's granulomatosis", 'Dense deposit disease', 'Hereditary nephropathy - other',
            'Focal segmental glomerulosclerosis with nephrotic syndrome in adults', 'Nephropathy caused by other specific drug', 
            'Traumatic or surgical loss of kidney', 'Gout', 'Renal vascular disease - classified'
        ]
    )

    df_pheno['OnDialysis'] = (df_pheno.OnDialysis.replace(
        {1:False, 2:True}
    )
    ).astype('bool')

    df_pheno['HasDiabetes'] = (df_pheno.HasDiabetes.replace(
        {0:False, 1:True}
    )
    ).astype('bool')

    df_pheno['IntracranialHaemorrhage'] = df_pheno.IntracranialHaemorrhage.replace(
        {1:False, 2:True, 9:None}
    ).astype('bool')
    
    df_pheno['GraftType_num'] = pd.Categorical(
        df_pheno.GraftType,
        categories=[10, 14]
    )

    df_pheno['GraftType'] = pd.Categorical(
        df_pheno.GraftType.map(dict_legend),
        categories=['Kidney only', 'Double kidney']
    )

    df_pheno['DonType'] = pd.Categorical(
        df_pheno.DonType.replace({1:0, 2:1}),
        categories=[
            0,1
        ]
    )   
    
    df_pheno['HLAMismatches'] = df_pheno.HLAMismatches.apply(sum_HLA)
    
    return df_pheno, dict_columns

df_pheno, dict_columns = clean(df_pheno)

# %% ../nbs/00_Clean.ipynb 41
impute_vars = list(df_pheno.isnull().mean()[df_pheno.isnull().mean() > 0].index)
impute_vars = impute_vars[:1] + impute_vars[3:]

# %% ../nbs/00_Clean.ipynb 44
df_pheno.to_pickle('data/interim/pheno_r.pkl')
