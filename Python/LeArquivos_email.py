# -*- coding: utf-8 -*-
"""
Created on Mon Oct 19 12:47:45 2020

@author: drika
"""

import csv
import pandas as pd
import unicodedata


def tira_acento(text):
	
	try:
		text = unicode(text, 'utf-8')
	except NameError:
		pass
	text = unicodedata.normalize('NFD', text).encode('ascii', 'ignore').decode("utf-8")
	return str(text)

#Ler Classes e transforma em dicionarios
#df = pd.read_csv("sgt_classes1.csv")
df = pd.read_excel("sgt_classes.xlsx",encoding='utf-8')
#dictionary = df.set_index(['codigo']).to_dict()
dic_classes = df.set_index(['codigo'])['descricao'].to_dict()

#Ler Assuntos e transforma em dicionarios
df = pd.read_excel("sgt_assuntos.xlsx",encoding='utf-8')
#dictionary = df.set_index(['codigo']).to_dict()
dic_assuntos = df.set_index(['codigo'])['descricao'].to_dict()

#Ler Assuntos e transforma em dicionarios
df = pd.read_excel("mpm_serventias.xlsx",encoding='utf-8')
#dictionary = df.set_index(['codigo']).to_dict()
dic_serventias = df.set_index(['SEQ_ORGAO'])['NOMEDAVARA'].to_dict()


#Ler Assuntos e transforma em dicionarios
df = pd.read_excel("emails_serventias.xlsx",encoding='utf-8')
#dictionary = df.set_index(['codigo']).to_dict()
dic_emails = df.set_index(['SERVENTIA'])['email'].to_dict()

#Ler todos os dados do Arquivo do Alberto
df = pd.read_csv("desafioCNJInter.csv",encoding='utf-8')
#df = pd.read_excel("sgt_classes.xlsx")

Classe = df['classe']
Assunto = df['assunto']
Serventia = df['serventia']


print(dic_classes[51])
print(dic_classes[51].encode("utf-8"))
print(dic_assuntos[1695])
print(dic_serventias[26])
print(df['classe'])
print(Classe[0])
print(Assunto[0])
print(Serventia[0])

print(dic_classes[Classe[0]])
print(dic_assuntos[Assunto[0]])
print(dic_serventias[Serventia[0]])
print(len(df))
#print(df[0])
print(df['classe'][0])
print(dic_classes[df['classe'][0]])
#print(dic_assuntos[df['assunto'][0]])
#print(dic_serventias[df['serventia'][0]])

# In Python 3 the required syntax changed (see documentation links below), so open outfile 
# with the additional parameter newline='' (empty string) instead.
with open('desafioCNJInter_nome_email_nomes.csv', mode='w', newline='', encoding="utf-8") as cnj_file:
    employee_writer = csv.writer(cnj_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    employee_writer.writerow(['idt','numero','classe','assunto',
                             'localidade','grau','serventia','municipio',
                             'tribunal','datajuizo','movimento1','movimento2',
                             'movimento3','datahora1','datahora2',
                             'datahora3','duracao1','duracao2','status',
                             'nomeclasse','nomeassunto','nomeserventia','email'])
    
    for i in range(0,len(df)):
     employee_writer.writerow([df['idt'][i],df['numero'][i],df['classe'][i],df['assunto'][i],
                              df['localidade'][i],df['grau'][i],df['serventia'][i],df['municipio'][i],
                              df['tribunal'][i],df['datajuizo'][i],df['movimento1'][i],df['movimento2'][i],
                              df['movimento3'][i], df['datahora1'][i],df['datahora2'][i],
                              df['datahora3'][i],df['duracao1'][i],df['duracao2'][i],df['status'][i],
                              tira_acento(dic_classes[df['classe'][i]]),
                              tira_acento(dic_assuntos[df['assunto'][i]]),
                              tira_acento(dic_serventias[df['serventia'][i]]),
                              tira_acento(dic_emails[df['serventia'][i]])
                              ])

cnj_file.close()

