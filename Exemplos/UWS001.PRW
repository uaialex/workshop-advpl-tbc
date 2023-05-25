#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTILW08
RestFul API para Integração Contratos Assistenciais
@type function
@version 1.0
@author Wellington Goncalves
@since 24/05/2023
/*/
User Function UWS0001
Return

WSRESTFUL ContratosAssistencias DESCRIPTION "EndPoint Workshop ADVPL - Contratos Assistenciais"

	WSDATA cCgcCliente	AS STRING    OPTIONAL

    WSMETHOD GET ConsultarContratos;
	DESCRIPTION "Consulta de Contratos";
	PATH "/consultarcontratos";
	WSSYNTAX "ContratosAssistencias/consultarcontratos/{cCgcCliente}"

END WSRESTFUL


WSMETHOD GET ConsultarCobrancas WSRECEIVE cCgcCliente WSSERVICE ContratosAssistencias

Local oResponse             := JsonObject():New()
Local oContrato             := NIL
Local oJsonBeneficiario     := NIL
Local cQuery                := ""	
Local aBeneficiarios        := {}
Local cContrato             := ""
Local lRet                  := .T.

Self:SetContentType("application/json; charset=utf-8")

cQuery := " SELECT 
cQuery += " SA1.A1_COD CLIENTE,
cQuery += " SA1.A1_LOJA LOJA,
cQuery += " SA1.A1_NOME NOME_CLIENTE,
cQuery += " ZZ1.ZZ1_CODIGO CONTRATO,
cQuery += " ZZ1.ZZ1_DATA DATA,
cQuery += " ZZ1.ZZ1_STATUS STATUS,
cQuery += " ZZ1.ZZ1_PRODUT PRODUTO,
cQuery += " SB1.B1_DESC DESCRICAO,
cQuery += " ZZ1.ZZ1_VALOR VALOR,
cQuery += " ZZ2.ZZ2_TIPO TIPO,
cQuery += " ZZ2.ZZ2_NOME NOME
cQuery += " FROM 
cQuery += RetSQLName("ZZ1") + " ZZ1 " 
cQuery += " INNER JOIN 
cQuery += RetSQLName("SA1") + " SA1 "
cQuery += " ON ZZ1.D_E_L_E_T_ = ' '
cQuery += " AND SA1.D_E_L_E_T_ = ' '
cQuery += " AND ZZ1.ZZ1_CLIENT = SA1.A1_COD
cQuery += " AND ZZ1.ZZ1_LOJA = SA1.A1_LOJA
cQuery += " INNER JOIN 
cQuery += RetSQLName("SB1") + " SB1 " 
cQuery += " ON SB1.D_E_L_E_T_ = ' '
cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'
cQuery += " AND SB1.B1_COD = ZZ1.ZZ1_PRODUT
cQuery += " INNER JOIN 
cQuery += RetSQLName("ZZ2") + " ZZ2 "
cQuery += " ON ZZ2.D_E_L_E_T_ = ' '
cQuery += " AND ZZ1.ZZ1_FILIAL = ZZ2.ZZ2_FILIAL
cQuery += " AND ZZ1.ZZ1_CODIGO = ZZ2.ZZ2_CODIGO
cQuery += " WHERE "
cQuery += " ZZ1.ZZ1_FILIAL = '" + xFilial("ZZ1") + "' "

if cCgcCliente <> NIL .And. !Empty(cCgcCliente)
    cQuery += " AND SA1.A1_CGC LIKE '%" + cCgcCliente + "%' "
endif

If Select("QCTT") > 0
    QCTT->(DbCloseArea())
EndIf

// executo a query e crio o alias temporario
FwExecCachedQuery():OpenQuery( cQuery, "QCTT", /*aSetField*/, /*cDriver*/, "300", "120")


If QCTT->( !EOF() )

	oResponse["status"]     := 200
	oResponse["contratos"]  := {}
    
    
    While QCTT->(!Eof())

        if cContrato <> QCTT->CONTRATO

            cContrato := QCTT->CONTRATO 

            if oContrato <> NIL

                oContrato["beneficiarios"] := aBeneficiarios
                AADD(oResponse["contratos"], oContrato )

            endif

            FreeObj(oContrato)
            oContrato  := JsonObject():New()
        
        
            oContrato["cliente"] := QCTT->CLIENTE
            oContrato["loja"] := QCTT->LOJA
            oContrato["nome"] := QCTT->NOME_CLIENTE
            oContrato["contrato"] := QCTT->CONTRATO
            oContrato["data"] := QCTT->DATA
            oContrato["status"] := QCTT->STATUS
            oContrato["produto"] := Alltrim(QCTT->PRODUTO)
            oContrato["descricao"] := Alltrim(QCTT->DESCRICAO)
            oContrato["valor"] := QCTT->VALOR

            aBeneficiarios := {}

        endif
        
        FreeObj(oJsonBeneficiario)
        oJsonBeneficiario := JsonObject():New()
        
	    oJsonBeneficiario["tipo"]   := AllTrim(QCTT->TIPO)
        oJsonBeneficiario["nome"]   := AllTrim(QCTT->NOME)

        Aadd(aBeneficiarios,oJsonBeneficiario)
        
        QCTT->(DbSkip())

        If QCTT->( EOF() )
			
            If oContrato <> Nil
                
                oContrato["beneficiarios"] := aBeneficiarios

				AADD(oResponse["contratos"], oContrato )
			
            EndIf
			
            FreeObj(oContrato)
		
        EndIf
            
    EndDo

else
    oResponse["status"] := 400
	oResponse["msg"]	:= "Nao ha titulos para consulta especificada"
endif

Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )


Return(lRet)
