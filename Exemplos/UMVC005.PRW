#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} UMVC005
Cadastro de Contratos 
@type function
@version 1.0
@author Raphael Martins
@since 5/24/2023
/*/

User Function UMVC005()
 
Local oBrowse

Private aRotina
Private cCadastro := 'Cadastro de Contratos Assistenciais'

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZZ1' )
oBrowse:SetDescription( cCadastro )
oBrowse:AddLegend("ZZ1_STATUS == 'P'", "WHITE"	, "Pre-cadastrado")
oBrowse:AddLegend("ZZ1_STATUS == 'A'", "GREEN"	, "Ativo")
oBrowse:AddLegend("ZZ1_STATUS == 'C'", "BLUE"	, "Cancelado")
	

oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
MenuDef de Contratos Assistenciais
@type function
@version 1.0
@author Raphael Martins
@since 5/24/2023
/*/
Static Function MenuDef()

aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.UMVC005' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'         ACTION 'VIEWDEF.UMVC005' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'         ACTION 'VIEWDEF.UMVC005' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'         ACTION 'VIEWDEF.UMVC005' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'        ACTION 'VIEWDEF.UMVC005' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'          ACTION 'VIEWDEF.UMVC005' OPERATION 9 ACCESS 0
ADD OPTION aRotina Title 'Legenda'     	   Action 'U_UMVC05LEG()' 	OPERATION 10 ACCESS 0

Return aRotina


/*/{Protheus.doc} ModelDef
ModelDef de Contratos Assistenciais
@type function
@version 1.0
@author Raphael Martins
@since 5/24/2023
/*/
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dadoso| Alltrim(cCampo) $ "B1_COD,B1_DESC,B1_UM,B1_TIPO" },/*lViewUsado*/ )
Local oStruZZ1  := FWFormStruct( 1, 'ZZ1', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZZ2  := FWFormStruct( 1, 'ZZ2', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('UMVCP005', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulario de edicao por campo
oModel:AddFields( 'ZZ1MASTER', /*cOwner*/, oStruZZ1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "ZZ1_FILIAL", "ZZ1_CODIGO" })

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'ZZ2DETAIL', 'ZZ1MASTER', oStruZZ2 , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'ZZ2DETAIL', { {'ZZ2_FILIAL', 'xFilial( "ZZ2" )'}, {'ZZ2_CODIGO', 'ZZ1_CODIGO'} }, ZZ2->( IndexKey( 1 ) ) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZZ2DETAIL' ):SetUniqueLine( { 'ZZ2_CPF' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Beneficiarios do Contrato' )

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'ZZ2DETAIL' ):SetDescription( 'Beneficiarios' )

Return oModel

/*/{Protheus.doc} ModelDef
ViewDef de Contratos Assistenciais
@type function
@version 1.0
@author Raphael Martins
@since 5/24/2023
/*/
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'UMVC005' )
Local oView

// Cria a estrutura a ser usada na View
Local oStruZZ1 := FWFormStruct( 2, 'ZZ1' )
Local oStruZZ2 := FWFormStruct( 2, 'ZZ2' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados serÂ· utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddField( 'VIEW_ZZ1', oStruZZ1, 'ZZ1MASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_ZZ2', oStruZZ2, 'ZZ2DETAIL' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZZ2', 'ZZ2_ITEM' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'CIMA'	, 70 )
oView:CreateHorizontalBox( 'BAIXO'	, 30 )

// Cria um "box" vertical para receber cada elemento da view
//oView:CreateVerticalBox( 'CIMA'	, 60 )
//oView:CreateVerticalBox( 'BAIXO', 40 )

// Relaciona o identificador (ID) da View com o "box" para exibiÃ§Ã£o
oView:SetOwnerView( 'VIEW_ZZ1', 'CIMA' )
oView:SetOwnerView( 'VIEW_ZZ2', 'BAIXO' )

// titulo dos componentes
oView:EnableTitleView('VIEW_ZZ1')
oView:EnableTitleView('VIEW_ZZ2')

Return oView

/*/{Protheus.doc} UMVC05LEG
Apresentacao da Legenda dos status dos Contratos
@type function
@version 1.0
@author raphaelgarcia
@since 5/24/2023
/*/
User Function UMVC05LEG()

	BrwLegenda("Status do Contrato","Legenda",;
    {{"BR_BRANCO","Pré-Cadastro"},;
    {"BR_VERDE","Ativo"},;
    {"BR_AZUL","Cancelado"}})

Return()
