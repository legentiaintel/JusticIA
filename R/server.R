#
#    http://shiny.rstudio.com/
#

library(shiny)

shinyServer(function(input, output) {

    options(shiny.maxRequestSize = 30*1024^2)
    currwd <- getwd()
    caminho = paste0(currwd, "", collapse = "") # diretorio onde estao os DADOS
    caminhoSaida = paste0(currwd, "", collapse = "") # diretorio onde estao os DADOS
    arquivoscarregados<<-0

      ###### ENTRADA DE DADOS E SELEÇÃO DO GRAU ######    
      observeEvent(input$files, {
        fileFrom = ""
        fileTo = ""
        s = ""
        files = input$files
        for(i in nrow(files):1){
            data <- read.csv2 (input$files[[i, 'datapath']],sep=",")
            fileName = files[i, "name"]
            # Write the file to the local system
        }
        dados<<-data # base de dados
        
        # processos por grau
        grau=dados[,6]
        output$plotprograu <- renderPlot({
          barplot(sort(table(grau),decreasing=T),col="black",ylab="Processos",main="Distribuição dos processos por grau")
        })
        
        # lista para seleção do grau
        saidagrau=data.frame(sort(table(grau),decreasing=T))
        colnames(saidagrau)=c("Grau","Número de processos")
        output$tablegrau <- DT::renderDataTable({
          DT::datatable(saidagrau)
        })

        # grava arquivo para uso interno    
        observeEvent(input$tablegrau_rows_selected, {
           variavel = input$tablegrau_rows_selected
           variavelgrauselecionado<<-variavel
        #  write.csv2(variavel,"grau.csv")
        })
        
        # graus selecionados
        #output$x01 = renderPrint({
        #  s = input$tablegrau_rows_selected
        #  if (length(s)) {
        #    cat('Grau selecionado:\n\n')
        #    cat(s, sep = ', ')
        #  }
        #})    
        
      })

      # filtra dados pelo grau selecionado
      observeEvent(input$do_grau, {
           listagrau=as.numeric(variavelgrauselecionado)
           resultadograu=table(dados[,6])
           resultadograu=sort(resultadograu,decreasing=T)
           saidagrau=data.frame(resultadograu)
           grauselec<<-as.character(saidagrau[listagrau,1])
           if (length(grauselec)<=1){
             if (length(grauselec)==1) {indice=grep(grauselec,dados[,6])}
           } else {
             indice=c()
             for (i in 1:length(grauselec)){
               indice=c(indice,grep(grauselec,dados[,6]))
             }
           }
           dadosf<<-dados[indice,] # dados filtrado pelo grau
           
           aux=paste(dadosf[,7],dadosf[,22]) # numero e nome da serventia
           resultado=table(aux)
           ordem=sort(as.numeric(resultado),decreasing=T,index.return=T)
           saida=data.frame(resultado[ordem$ix])
           names(saida)=c("Serventia","Numero de Processos")
           status=dadosf[,19]
           classe=dadosf[,3]
           assunto=dadosf[,4]
           resultado=table(dadosf[,7])
           resultado=resultado[ordem$ix]
           
           # total de processos por serventia
           output$plot1 <- renderPlotly({
             #barplot(resultado,las=3,main=paste("Total de processos por serventias em",grauselec),col="black",ylab="Processos")
             #mediana=quantile(resultado,0.5)
             #lines(c(0,5*dim(resultado)[1]),c(mediana,mediana),lwd=3,col="blue")
             x=c()
             for (i in 1:length(names(resultado))) {
                 x=c(x,strsplit(names(resultado)," ")[[i]][1])
             }
             y=as.numeric(resultado)
             text=names(resultado)
             titulo=paste("Total de processos por serventias em",grauselec)
             xform<-list(categoryorder="x",categoryarray=x)
             fig=plot_ly(x=x,y=y,name=text,type='bar')%>% 
               layout(xaxis = xform) %>% layout(showlegend = FALSE)
             fig<-fig %>% layout(title = titulo,
                                  xaxis = list(title = ""),
                                  yaxis = list(title = "Processos"))
           })
           
           # lista para seleção da serventia
           output$table1 <- DT::renderDataTable({
             DT::datatable(saida)
           })
           
           # serventias selecionadas
           #output$x1 = renderPrint({
           #   s = input$table1_rows_selected
           #  if (length(s)) {
           #     cat('Varas selecionadas:\n\n')
           #     cat(s, sep = ', ')
           #  }
           #})
           
           # grava arquivo para uso interno    
           observeEvent(input$table1_rows_selected, {
             variavel = input$table1_rows_selected
             variavalvaraselec<<-variavel
           })    
           
           # grava arquivo para uso interno    
           observeEvent(input$corte, {
             variavel = input$corte
             variavelcorte<<-variavel
           })    
           
      })
      
      # seleciona serventia
      observeEvent(input$do_serventia, {
        
        aux=paste(dadosf[,7],dadosf[,22]) # numero e nome da serventia
        resultado=table(aux)
        ordem=sort(as.numeric(resultado),decreasing=T,index.return=T)
        saida=data.frame(resultado[ordem$ix])
        names(saida)=c("Serventia","Número de Processos")
        status=dadosf[,19]
        classe=dadosf[,3]
        assunto=dadosf[,4]
        resultado=table(dadosf[,7])
        resultado=resultado[ordem$ix]
        
        # processos por status em cada serventia
        output$plotstatusx <- renderPlotly({
          tabelao1=table(dadosf[,7],status)
          tabelao1prop=prop.table(t(tabelao1[ordem$ix,]),2)
          # barplot(tabelao1prop,2,las=3,main="Status dos processos nas serventias")
          # mycols = c("green", "yellow", "blue")
          # opar = par(oma = c(2,0,0,0))
          # barplot(tabelao1prop,2,las=3,col=mycols,ylab="",main=paste("Status dos processos nas serventias em",grauselec))
          # par(opar)
          # opar = par(oma = c(0,0,0,0), mar = c(0,0,0,0), new = TRUE)
          # legend(x = "bottom", legend = rownames(tabelao1prop), bty = "n", inset=-0.16,ncol=3,fill = mycols)
          # par(opar) # Reset par
          baixado=tabelao1prop[1,]*100
          distrib=tabelao1prop[2,]*100
          julgado=tabelao1prop[3,]*100
          nomes1=colnames(tabelao1prop)
          grafico=data.frame(nomes1,baixado,distrib,julgado)
          xform<-list(categoryorder="nomes1",categoryarray=nomes1)
          fig <- plot_ly(grafico,x=nomes1,y=baixado,type='bar',name='baixados')
          fig <- fig %>% add_trace(y =distrib, name = 'distribuídos')
          fig <- fig %>% add_trace(y =julgado, name = 'julgados')
          fig <- fig %>% layout(yaxis = list(title = '%'), barmode = 'stack')
          fig <- fig %>% layout(xaxis = xform)
          fig
        })
        
        # processos por status
        output$plotstatus <- renderPlot({
          barplot(sort(table(status),decreasing=T),ylab="Processos",col="blue",main=paste("Distribuição dos processos por status em",grauselec))
        })
        
        # processos por classe
        output$plotprocclasse <- renderPlotly({
          #barplot(sort(table(classe),decreasing=T),ylab="Processos",col="green",las=3,main=paste("Distribuição dos processos por classe em",grauselec))
          x=names(sort(table(classe),decreasing=T))
          y=as.numeric(sort(table(classe),decreasing=T))
          text=x
          titulo=paste("Distribuição dos processos por classe em",grauselec)
          xform<-list(categoryorder="x",categoryarray=x)
          fig<-plot_ly(x=x,y=y,name=text,type='bar')%>% 
            layout(xaxis = xform) %>% layout(showlegend = FALSE)
          fig<- fig %>% layout(title = titulo,
                               xaxis = list(title = ""),
                               yaxis = list(title = "Processos"))        
          
        })
        
        # processos por assunto
        output$plotprocassunto <- renderPlotly({
          #barplot(sort(table(assunto),decreasing=T),ylab="Processos",col="orange",las=3,main=paste("Distribuição dos processos por assunto em",grauselec))
          x=names(sort(table(assunto),decreasing=T))
          y=as.numeric(sort(table(assunto),decreasing=T))
          text=x
          titulo=paste("Distribuição dos processos por assunto em",grauselec)
          xform<-list(categoryorder="x",categoryarray=x)
          fig<-plot_ly(x=x,y=y,name=text,type='bar')%>% 
            layout(xaxis = xform) %>% layout(showlegend = FALSE)
          fig<- fig %>% layout(title = titulo,
                              xaxis = list(title = ""),
                              yaxis = list(title = "Processos"))        
          
        })
        
        lista=variavalvaraselec
        resultado=table(dadosf[,7])
        resultado=sort(resultado,decreasing=T)
        saida=data.frame(resultado)
        varaselec<<-as.numeric(as.character(saida[lista,1]))
        if (length(varaselec)<=1){
          if (length(varaselec)==1) {indice=which(dadosf[,7]==varaselec)}
        } else {
          indice=c()
          for (i in 1:length(varaselec)){
            indice=c(indice,which(dadosf[,7]==varaselec[i]))
          }
        }
        
        pcorte=variavelcorte
        
        resultado=table(dadosf[indice,3])
        resultado=sort(resultado,decreasing=T)
        output$plot2classe <- renderPlot({
          participa=sum(as.numeric(resultado[1:pcorte]),na.rm=T)*100/sum(as.numeric(resultado),na.rm=T)
          participa=paste(as.character(round(participa,0)),"%",sep="")
          if (length(varaselec)<=1){
            listavara=varaselec
          } else {
            listavara=c()
            for (i in 1:length(varaselec)){
              listavara=paste(listavara,varaselec[i])
            }
          }
          if (pcorte>10){
            barplot(resultado[1:pcorte],ylab="Processos",las=3,col="blue",main=paste("Top",pcorte,"classes",participa,"dos processos na serventia",listavara))
          } else {
            barplot(resultado[1:pcorte],ylab="Processos",col="blue",main=paste("Top",pcorte,"classes",participa,"dos processos na serventia",listavara))
          }
        })
        
        resultado1=table(dadosf[,3])
        resultado1=sort(resultado1,decreasing=T)
        output$plot3classeall <- renderPlot({
          participa=sum(as.numeric(resultado1[1:pcorte]),na.rm=T)*100/sum(as.numeric(resultado1),na.rm=T)
          participa=paste(as.character(round(participa,0)),"%",sep="")
          if (pcorte>10){
            barplot(resultado1[1:pcorte],las=3,ylab="Processos",col="blue",main=paste("Top",pcorte,"classes",participa,"dos processos em",grauselec))
          }else{
            barplot(resultado1[1:pcorte],col="blue",ylab="Processos",main=paste("Top",pcorte,"classes",participa,"dos processos em",grauselec))
          }
        })
        
        resultado2=table(dadosf[indice,4])
        resultado2=sort(resultado2,decreasing=T)
        output$plot4assunto <- renderPlot({
          participa=sum(as.numeric(resultado2[1:pcorte]),na.rm=T)*100/sum(as.numeric(resultado2),na.rm=T)
          participa=paste(as.character(round(participa,0)),"%",sep="")
          if (length(varaselec)<=1){
            listavara=varaselec
          } else {
            listavara=c()
            for (i in 1:length(varaselec)){
              listavara=paste(listavara,varaselec[i])
            }
          }
          if (pcorte>10){
            barplot(resultado2[1:pcorte],las=3,col="green",main=paste("Top",pcorte,"assuntos",participa,"dos processos na vara",listavara))
          }else{
            barplot(resultado2[1:pcorte],col="green",main=paste("Top",pcorte,"assuntos",participa,"dos processos na vara",listavara))
          }              
        })
        
        resultado3=table(dadosf[,4])
        resultado3=sort(resultado3,decreasing=T)
        output$plot5assuntoall <- renderPlot({
          participa=sum(as.numeric(resultado3[1:pcorte]),na.rm=T)*100/sum(as.numeric(resultado3),na.rm=T)
          participa=paste(as.character(round(participa,0)),"%",sep="")
          if (pcorte>10){
            barplot(resultado3[1:pcorte],las=3,col="green",main=paste("Top",pcorte,"assuntos",participa,"dos processos em",grauselec))
          }else{
            barplot(resultado3[1:pcorte],col="green",main=paste("Top",pcorte,"assuntos",participa,"dos processos em",grauselec))
          }
        })
        
        # grafico comparativo          
        resultado4=table(dadosf[indice,4])
        resultado5=table(dadosf[,4])
        indice1=intersect(names(resultado4),names(resultado5))
        aux4=c()
        aux5=c()
        for (i in 1:length(indice1)){
          iaux=which(names(resultado4)==indice1[i])
          aux4=c(aux4,resultado4[iaux])
          iaux=which(names(resultado5)==indice1[i])
          aux5=c(aux5,resultado5[iaux])
        }
        counts <- data.frame(aux4,aux5)
        rownames(counts)=indice1
        output$plot6 <- renderPlotly({
          if (length(varaselec)<=1){
            listavara=varaselec
          } else {
            listavara=c()
            for (i in 1:length(varaselec)){
              listavara=paste(listavara,varaselec[i])
            }
          }
          if (length(varaselec)==1){
            listavara=paste("serventia",listavara)
          } else {
            listavara=paste("serventias",listavara)
          }
          colnames(counts)=c(listavara,grauselec)
          #barplot(as.matrix(counts), main="Comparativo",
          #        xlab="", col=c("darkblue","red"),
          #        legend = rownames(counts), beside=TRUE)
          ordemy=sort(counts[,2],decreasing=T,index.return=T)$ix
          x=counts[ordemy,2]
          xform<-list(categoryorder="x",categoryarray=x)
          
          fig <- plot_ly()
          fig <- fig %>% add_bars(
            y = rownames(counts)[ordemy],
            x = counts[ordemy,2],
            base = 0,
            marker = list(color = 'blue'),
            name = grauselec, orientation = 'h'
          ) %>% layout(yaxis = xform) %>% layout(showlegend = T)

          fig <- fig %>% add_bars(
            y = rownames(counts)[ordemy],
            x = -counts[ordemy,1],
            base = 0,
            marker = list(color = 'red'),
            name = listavara, orientation = 'h'
          ) %>% layout(yaxis = xform) %>% layout(showlegend = T)
          fig<- fig %>% layout(title = "Análise comparativa",
                               xaxis = list(title = "Processos"),
                               yaxis = list(title = "Assuntos"))        

        })
      })  

      # grava arquivo para uso interno
      observeEvent(input$cluster, {
          variavel = input$cluster
          variavelseleccluster<<-variavel
      })    
      
      #### executa 
      observeEvent(input$do, {
        
          # analise de agrupamentos
          pdcluster=variavelseleccluster
          nomeslinhas=paste(dadosf[,7],dadosf[,22],collapese=T)
          
          #varaclasse=table(dadosf[,7],dadosf[,3]) #vara x classes
          varaclasse=table(nomeslinhas,dadosf[,3]) #vara x classes
          indicevaraclasse=cumsum(sort(apply(varaclasse,2,sum),decreasing=T)*100/sum(apply(varaclasse,2,sum)))
          i1=which(indicevaraclasse<99)
          if (length(which(apply(varaclasse[,i1],1,sum)==0))>0){
             i1=which(indicevaraclasse<101)
          }
          classesimporta=names(indicevaraclasse[i1])
          classeresumo=c()
          nomesaux=c()
          for (i in 1:length(classesimporta)){
              iaux=which(colnames(varaclasse)==classesimporta[i])
              classeresumo=cbind(classeresumo,varaclasse[,iaux])
              nomesaux=c(nomesaux,colnames(varaclasse)[iaux])
          }
          colnames(classeresumo)=nomesaux
          #varaassunto=table(dadosf[,7],dadosf[,4]) #vara x assunto
          varaassunto=table(nomeslinhas,dadosf[,4]) #vara x assunto
          indicevaraassunto=cumsum(sort(apply(varaassunto,2,sum),decreasing=T)*100/sum(apply(varaassunto,2,sum)))
          i1=which(indicevaraassunto<75)
          if (length(which(apply(varaassunto[,i1],1,sum)==0))>0){
            i1=which(indicevaraassunto<100)
          }
          assuntoimporta=names(indicevaraassunto[i1])
          assuntoresumo=c()
          for (i in 1:length(assuntoimporta)){
              iaux=which(colnames(varaassunto)==assuntoimporta[i])
              assuntoresumo=cbind(assuntoresumo,varaassunto[,iaux])    
          }

          # FAZ ANALISE DE CORRESPONDENCIA MULTIPLA E DEPOIS APLICA KMEANS          
          tabelao=cbind(classeresumo,assuntoresumo)
          rotulo0=c()
          for (j in 1:dim(tabelao)[1]){
            rotulo0=c(rotulo0,strsplit(rownames(tabelao)[j]," ")[[1]][1])
          }
          #library(FactoMineR)
          #library(factoextra)
          saida1=CA(tabelao,graph=F) # analise de correspondencia
          # mapa das varas no plano fatorial
          coordenada=saida1$row$coord
          rownames(coordenada)=rotulo0
          output$plotca <- renderPlot({
              inercia=saida1$svd$vs^2/sum(saida1$svd$vs^2)
              titulo=paste("Serventias no mapa gerado por Análise de Correspondência - inércia",round(sum(inercia[1:2])*100,0),"%")
              plot(coordenada[,1],coordenada[,2],cex=1.2,pch=20,col="blue",main=titulo,xlab="dimensão 1",ylab="dimensão 2")
              if (length(varaselec)==1){
                  icoord=which(rownames(coordenada)==varaselec)
                  points(coordenada[icoord,1],coordenada[icoord,2],col="red",pch=20,cex=2)
              } else {
                  for (i in 1:length(varaselec)){
                      icoord=which(rownames(coordenada)==varaselec[i])
                      points(coordenada[icoord,1],coordenada[icoord,2],col="red",pch=20,cex=2)
                  }
              }
          })
          # faz o KMeans
          set.seed(1513)
          coordenada1=coordenada
          rownames(coordenada1)=rownames(tabelao)
          saidacluster=kmeans(coordenada1[,1:2],pdcluster,iter.max=5000) # kmeans
          BSS=round(100*saidacluster$betweenss/saidacluster$totss,0)
          rotulo=saidacluster$cluster # cluster
          rotulo1=c()
          for (j in 1:length(rotulo)){
              rotulo1=c(rotulo1,strsplit(names(rotulo)[j]," ")[[1]][1])
          }
          if (length(varaselec)<=1){
              #icluster=which(as.numeric(names(rotulo))==varaselec)
              icluster=which(as.numeric(rotulo1)==varaselec)
              tabelavaracluster=data.frame(varaselec,rotulo[icluster])
              names(tabelavaracluster)=c("vara","cluster")
          } else {
              icluster=c()
              for (i in 1:length(varaselec)){
                  #iaux=which(as.numeric(names(rotulo))==varaselec[i])
                  iaux=which(as.numeric(rotulo1)==varaselec[i])
                  icluster=c(icluster,rotulo[iaux])
              }
              tabelavaracluster=data.frame(varaselec,icluster)
              names(tabelavaracluster)=c("vara selecionada","cluster")
          }
          
          # tabela com os cluster das varas selecionadas
          output$table2 <- DT::renderDataTable({
              DT::datatable(tabelavaracluster)
          })
          
          # classes dos clusters
          for (i in 1:dim(varaclasse)[2]){
              aux=aggregate(varaclasse[,i],list(rotulo),sum)[2]
              if (i==1) {
                 resumo=aux                      
              }else{
                 resumo=cbind(resumo,aux)
              }
          }
          colnames(resumo)=colnames(varaclasse)
          
          # varas por cluster
          output$plotresumoclasse1 <- renderPlot({
              titulo=paste("Total de serventias em cada cluster K-Means - Between Sum Squares",BSS,"%")
              barplot(table(rotulo),xlab="clusters",ylab="frequencia",col="black",main=titulo)
          })

          # processos em cada cluster
          output$plotresumoclasse2 <- renderPlot({
             aux=apply(resumo,1,sum)
             names(aux)=rownames(resumo)
             barplot(aux,xlab="clusters",ylab="frequencia",col="black",main="Total de processos em cada cluster")
          })
          
          # distribuicao das classes em cada cluster
          output$plotresumoclasse3 <- renderPlot({
             proporcoes=100*prop.table(t(resumo),margin=2)
             colnames(proporcoes)=rownames(resumo)
             barplot(proporcoes,xlab="clusters",ylab="%",main="Distribuicao das classes por clusters")
          })

          # tabela com os clusters das varas
          output$table3 <- DT::renderDataTable({
              tabelaclustervara=data.frame(names(rotulo),rotulo)
              rownames(tabelaclustervara)=c()
              colnames(tabelaclustervara)=c("serventia","cluster")
              DT::datatable(tabelaclustervara)
          })

          output$plotcaclusters <- renderPlot({
            inercia=saida1$svd$vs^2/sum(saida1$svd$vs^2)
            titulo=paste("Serventias no mapa gerado por Análise de Correspondência - inércia",round(sum(inercia[1:2])*100,0),"%")
            #plot(coordenada[,1],coordenada[,2],cex=1.2,pch=20,col="blue",main=titulo,xlab="dimensão 1",ylab="dimensão 2")
            base=coordenada[,1:2]
            p.cluster<-fviz_cluster(list(data=base,cluster=rotulo),repel=T,palett="Dark2",
                                    ggtheme = theme_minimal(), main = titulo, 
                                    show.clust.cent = F)+labs(fill="Cluster")+guides(col=F, shape=F)
            
            plot(p.cluster)
            if (length(varaselec)==1){
              icoord=which(rownames(coordenada)==varaselec)
              points(coordenada[icoord,1],coordenada[icoord,2],col="red",pch=20,cex=2)
            } else {
              for (i in 1:length(varaselec)){
                icoord=which(rownames(coordenada)==varaselec[i])
                points(coordenada[icoord,1],coordenada[icoord,2],col="red",pch=20,cex=2)
              }
            }
          })
          
          # analise das duracoes
          dura1=round(as.numeric(dadosf[,17]),0)
          dura2=round(as.numeric(dadosf[,18]),0)
          dura3=dura1+dura2
          v1=paste(dadosf[,7],dadosf[,22])
          resumodura=aggregate(data.frame(dura1,dura2,dura3),list(v1),mean)
          rownames(resumodura)=resumodura[,1]
          resumodura=resumodura[,c(2,3,4)]
          colnames(resumodura)=c("duracao1","duracao2","total")
          
          output$plotresumoduracao1 <- renderPlot({
            v1=resumodura[,1]
            nomes1=table(paste(dados[,7],dadosf[,22]))
            aux=c()
            for (i in 1:length(v1)){
                aux=c(aux,as.numeric(strsplit(names(nomes1)[i]," ")[[1]][1]))  
            }
            names(v1)=aux
            barplot(sort(v1,decreasing=T),xlab="serventia",ylab="dias",col="blue",las=3,main=paste("Duração média até julgamento por serventia em",grauselec))
            lines(1:100,rep(mean(as.numeric(v1)),100),col="red")
          })

          output$plotresumoduracao2 <- renderPlot({
            v2=resumodura[,2]
            nomes1=table(paste(dadosf[,7],dadosf[,22]))
            aux=c()
            for (i in 1:length(v2)){
              aux=c(aux,as.numeric(strsplit(names(nomes1)[i]," ")[[1]][1]))  
            }
            names(v2)=aux
            barplot(sort(v2,decreasing=T),xlab="serventia",ylab="dias",col="green",las=3,main=paste("Duração média até a baixa por serventia em",grauselec))
            lines(1:100,rep(mean(as.numeric(v2)),100),col="black")
          })
          output$plotresumoduracao3 <- renderPlot({
            v2=resumodura[,3]
            nomes1=table(paste(dadosf[,7],dadosf[,22]))
            aux=c()
            for (i in 1:length(v2)){
              aux=c(aux,as.numeric(strsplit(names(nomes1)[i]," ")[[1]][1]))  
            }
            names(v2)=aux
            barplot(sort(v2,decreasing=T),xlab="serventia",ylab="dias",col="orange",las=3,main=paste("Duração média por serventia",grauselec))
            lines(1:100,rep(mean(as.numeric(v2)),100),col="black")
          })
      
          output$scatterplotdura <- renderPlot({
            v1=resumodura[,1]
            v2=resumodura[,2]
            nomes1=table(paste(dadosf[,7],dadosf[,22]))
            aux=c()
            for (i in 1:length(v1)){
              aux=c(aux,as.numeric(strsplit(names(nomes1)[i]," ")[[1]][1]))  
            }
            names(v1)=aux
            plot(v1,v2,xlab="duracao média até o julgamento1",ylab="duracao média até a baixa",main="Durações em cada serventia (em dias)",pch=20,col="blue")
            if (length(varaselec)==1){
                icoord=which(names(v1)==varaselec)
                points(v1[icoord],v2[icoord],col="red",pch=20,cex=2)
            } else {
                for (i in 1:length(varaselec)){
                    icoord=which(names(v1)==varaselec[i])
                    points(v1[icoord],v2[icoord],col="red",pch=20,cex=2)
                }
            }
          })
          # tabela com as duracoes
          output$tabledura <- DT::renderDataTable({
            tabeladura=round(resumodura,0)
            colnames(tabeladura)=c("duração até o julgamento","duração até a baixa","Total (dias)")
            DT::datatable(tabeladura)
          })

          # exporta dados agregados por serventia
          metasserventias=data.frame(resumodura,rotulo)
          metas=aggregate(metasserventias[,c(1,2,3)],list(rotulo),mean)
          aux=c()
          for (i in 1:dim(metasserventias)[1]){
              aux=c(aux,metas[rotulo[i],4])
          }
          metasserventias=data.frame(resumodura,aux)
          colnames(metasserventias)=c("duração até o julgamento","duração até a baixa","duração total","meta")
          output$downloadDataGlobal <- downloadHandler(
            filename = paste0("Dados_serventias",".csv",collapse=""),
            content = function(filename) {
              write.csv2(metasserventias,filename,row.names=T,dec=",",sep=";")
            }
          )
          
          # tabela com as metas
          output$tablemetas <- DT::renderDataTable({
            tabelametas=round(metasserventias,0)
            colnames(tabelametas)=c("duração até o julgamento","duração até a baixa","Total","Meta")
            DT::datatable(tabelametas)
          })

          output$plotmetas <- renderPlotly({
            v1=metasserventias[,3]
            v2=metasserventias[,4]
            metas1=data.frame(v1,v2)
            aux=c()
            for (i in 1:dim(metasserventias)[1]){
                aux=c(aux,as.numeric(strsplit(rownames(metasserventias)[i]," ")[[1]][1]))
            }
            rownames(metas1)=aux
            colnames(metas1)=c("duração média corrente","META")
            #mycols = c("yellow","blue")
            #opar = par(oma = c(2,0,0,0))
            #barplot(t(metas1),beside=T,las=3,col=mycols,main="durações atuais e metas por serventia")
            #par(opar)
            #opar = par(oma = c(0,0,0,0), mar = c(0,0,0,0), new = TRUE)
            #legend(x = "bottom", legend = colnames(metas1), bty = "n", inset=-0.16,ncol=3,fill = mycols)
            #par(opar) # Reset par 
            x<-as.character(aux)
            y1<-v1
            y2<-v2
            grafico<-data.frame(x,y1,y2)
            #grafico$x <- factor(grafico$x, levels = data[["x"]])
            fig <- plot_ly(grafico,x=~x,y=~y1, type = 'bar', name = 'duração corrente', marker = list(color = 'rgb(49,130,189)'))
            fig <- fig %>% add_trace(y=~y2,name='meta de duração', marker = list(color = 'rgb(204,204,204)'))
            fig <- fig %>% layout(xaxis= list(title="",tickangle=-90),
                                  yaxis= list(title="dias"),
                                  margin=list(b = 100),
                                  barmode='group')
            fig
          })
                    
          
      })
  })
