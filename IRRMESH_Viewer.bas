#Inclib "bIrrlicht"
#Include "fb_Irrlicht.bi"

Declare Sub LeeEntidades ()   ' lee el archivo extension .ENT para sacar luces y objetos desde el
Declare Sub LeeDatos()        ' se encarga de coger la info entre "{}" de las entidades anteriores
Declare Sub PosicionaObjeto() ' ponemos la entidad localizada en su sitio, dentro del mapa

' variables de las entidades (luces, objetos y demas)
Type entidad
	  tipo         As String
	  posicion(1 To 3)  As Single
	  tono(1 To 3)      As Single
	  rango        As Single
	  direccion(1 To 3) As Single
	  innerang     As Single
	  outerang     As Single
	  dirx         As Single
	  diry         As Single
	  dirz         As Single
	  objeto       As String
	  escala(1 To 3)    As Single
	  angulo(1 To 3)    As Single
	  zonazoom(1 To 3)  As Single
	  fantasma     As Single
	  automapa     As Single
	  texturaesc(1 To 2)As Single
End Type
Dim Shared objeto(1000) As entidad ' reservamos espacio 
Dim Shared nObjeto As Long ' y aqui los vamos contando
nObjeto=1

' variables de rotacion de camara
dim xcamrot as single
dim ycamrot as single
dim zcamrot as Single
' variables de posicion de camara
dim xposnod as single
dim yposnod as single
dim zposnod as Single
' posicion del raton
Dim mx as single
dim my as Single
' 
dim bspmesh as Integer
Dim Shared bspnode as Integer
Dim camera as Integer
dim cameranode as Integer
dim Shared mapcollision as Integer
dim bitmapfont as Integer
dim ret as Integer

' lecturas de teclado y raton
dim keyevent as Integer ptr
dim mouseevent as Integer Ptr

' variables para impresion de informacion en pantalla
Dim nodpos as wstring * 256
dim camrot as wstring * 256


iIrr3D( 800, 600, 32, FALSE )

iAppTitle( "Visualizador de mallas statics IRRMESH de Irrlicht" )

' mapa a leer
Dim Shared rutas As String
dim Shared mundo as string 
Dim As Integer xini, yini, zini
	
' -----------------------------------------------------
#If 1
	' activar estas dos que siguen para iluminar todo
	' cuestion de pruebas...
	iShadowColor( 130, 0, 0, 0 )
	iAmbientLight( .3, .3, .3 )
#EndIf

#If 0
	' hospital
	rutas = "hospital\"
	mundo = "HospitalPiso1-2"
	xini=200
	yini=100 ' vertical en la Y
	zini=100
	' activar las luces arriba
#EndIf

#If 0
	' castillo
	rutas = "castillo\"
	mundo = "castillo"
	xini=140
	yini=120 ' vertical en la Y
	zini=500
#EndIf

#If 1
	' test de luces IRRLITCH
	rutas = "test\"
	mundo = "test"
	xini=95
	yini=75 ' vertical en la Y
	zini=200
#EndIf

#If 0
	' el mapa del MAPSCAPE anterior a la V3
	rutas = "map\"
	mundo = "map"
	xini=55
	yini=40 ' vertical en la Y
	zini=80
#EndIf

#If 0
	' una habitacion suelta para pruebas
	rutas = "habitacion\"
	mundo = "habitacion"
	xini=95
	yini=70 ' vertical en la Y
	zini=500
#EndIf
' ---------------------------------------------------------



' leemos el mapa, y creamos la malla
Dim As String map=rutas+mundo+".irrmesh"
bspmesh = iLoadMesh ( map )
bspnode = iaddmeshtoscene( bspmesh )


Dim Shared LuzText as integer ' una textura de pruebas para la unica luz que uso ahora mismo
LuzText = iLoadTexture( rutas+"\texturas\luz.bmp" )

' si no hay luces creadas, ni mapas de luz, debemos apagar los efectos de luz
' nota: parece que NO afectan, asi que los apago
'iNodeMaterialFlag( bspnode, IRR_EMF_LIGHTING, 0 )
'iNodeMaterialFlag( bspNode, IRR_EMF_NORMALIZE_NORMALS, 0)

' pasamos a leer el archivo extension .ENT con luces y objetos
LeeEntidades()

' activo sombras y ambiente oscuro (probar sin el para ver el efecto)
iNodeShadow( bspnode )



' camara = mesh, rotatespeed, movespeed, id, keymaparray, keymapsize, novericalmovement, jumpspeed
camera = iCreateFPSCamera(0,100.0,.2,-1,0,0,0,0.0)
cameranode = camera
iPositionNode( cameranode, xini, yini, zini )
iCameraTarget( cameranode, xini+10, yini, zini-10 )


' mapa de colisiones
mapcollision = iGetCollisionGroupFromComplexMesh( bspmesh, bspnode, 0 ) ' 0=cuadro
ret = icollisionanimator(_
                          mapcollision,_
                          cameranode,_
                          30.0,50.0,30.0,_
                          0.0,-20.0,0.0,_
                          0.0,70.0,0.0 ) ' 70 altura del suelo a la cabeza (yini+20)

' fuente de caracteres 
'bitmapfont = iLoadFont ( rutas+"sistema/fonthaettenschweiler.bmp" )

' cielo esferico o cubico (a gustos) (nota: el SKYDOME2.JPG es cielo noturno, y el SKYDOME.JPG, de atardecer)
'bspnode = waddskydometoscene( wgettexture(rutas+"sistema/skydome.jpg"), 32, 32, 1.0, 2.0, 2000.0 )

' cargamos una animacion de un arma en primera persona
'Dim gunmesh As Integer
'Dim gunanim As Integer
'Dim gunText as Integer
'
'gunText = iLoadTexture( rutas+"sistema/gun.jpg" )
'gunmesh = iLoadMesh   ( rutas+"sistema/gun.md2" )
'gunanim = iAddMeshToScene( gunmesh ) 
'iNodeTexture( gunanim, gunText, 0 )	
'iSetNodeAnimationRange ( gunanim, 24 , 95)

' es necesario "apagar" las luces del modelo, ya que, al no llevarlas, se oscurece por defecto.	 
'iNodeMaterialFlag( gunanim, TRUE, FALSE )

' posicionamos al jugador (GUN.MD2) en el lugar de la camara
'iAddChildToParent( gunanim, cameranode ) ' convertimos al jugador en hijo de la camara
'isetnodeposition ( gunanim, 0, 0, 0    ) ' lo posicionamos en el cero de la camara
'isetnoderotation ( gunanim, 0, -90, 0  ) ' lo giramos 90º para que mire de frente a la camara


ihidemouse()


' -----------------------------------------------------------------------------
' ---------------- bucle principal --------------------------------------------
' -----------------------------------------------------------------------------
While iRun() And (Not iKeyHit( KEY_ESCAPE ))

        ibeginscene()
    
        'mx = 0.5 : my = 0.5
        'isetmouseposition( mx, my )
        'xposnod=iNodeX( cameranode, 0 )
        'yposnod=iNodeX( cameranode, 0 )
        'zposnod=iNodeX( cameranode, 0 )
        'igetnoderotation( cameranode, xcamrot, ycamrot, zcamrot )
        'igetnoderotation( cameranode, xcamrot, ycamrot, zcamrot )
        'igetnoderotation( cameranode, xcamrot, ycamrot, zcamrot )

        
          ' cogemos info de la escena, para verla en la pantalla          
            'nodpos = "POSICION "+str(xposnod)+" , "+Str(yposnod)+" , "+Str(zposnod)
            'camrot = "ANGULOS  "+str(xcamrot)+" , "+Str(ycamrot)+" , "+Str(zcamrot)

        idrawscene()

       'i2dfontdraw ( bitmapfont, nodpos , 4, 4, 250, 24 )
       'i2dfontdraw ( bitmapfont, camrot , 4, 24, 250, 24 )
        
       iendscene()

Wend
iEndIrr3D()


' leemos las entidades tipo OBJETO o LUCES
Sub LeeEntidades()
	Dim sLinea As String
	Open rutas+mundo+".ENT" For Input As 1
	While Not (Eof(1))
		Line Input #1,sLinea
		sLinea=UCase(LTrim(RTrim(Left(sLinea,Len(sLinea)-1))))
		   'Print "Creada Entidad ";sLinea
		   objeto(nObjeto).tipo=sLinea
		   LeeDatos()   
		   PosicionaObjeto()
		   nObjeto+=1
	Wend
	Close 
End Sub

' sacamos la INFO de cada objeto encontrado
Sub LeeDatos()
		Dim sLinea As String
		Dim sElem As String
		' variables de uso general
		Dim a As Single
		Dim b As Single
		Dim c As Single
		
		While Not (Eof(1))
	   Line Input #1,sLinea
		If LTrim(left(sLinea,1))="{" Then ' empieza a recopilar info de la entidad 	
			While Not (Eof(1))
			  Line Input #1,sLinea	
			  If LTrim(Left(sLinea,1))="}" Then Exit Sub ' salimos de recopilar la info
		     sLinea=UCase(LTrim(RTrim(sLinea)))
		     sElem=rTrim(Left(sLinea, InStr(sLinea,":")-1)) ' variable de la entidad (antes de ":")
		     sLinea=Mid(sLinea,InStr(sLinea,":")+1) ' quitamos el inicio hasta pasado el ":"
		     sLinea=left(sLinea,InStr(sLinea,";")-1) ' quitamos el ";" final, y queda "pelada"
				
		     Select Case sElem
		     	
		     	Case "POSITION"
		     		a=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		b=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		c=Val(sLinea)
               objeto(nObjeto).posicion(1)=a
               objeto(nObjeto).posicion(2)=b
               objeto(nObjeto).posicion(3)=c
               
		     	Case "COLOR"
		     		a=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		b=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		c=Val(sLinea)
               objeto(nObjeto).tono(1)=a
               objeto(nObjeto).tono(2)=b
               objeto(nObjeto).tono(3)=c
               
		     	Case "RANGE"
		     		a=Val(sLinea)
               objeto(nObjeto).rango=a
		     		
		     	Case "DIRECTION"
		     		a=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		b=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		c=Val(sLinea)
               objeto(nObjeto).direccion(1)=a
               objeto(nObjeto).direccion(2)=b
               objeto(nObjeto).direccion(3)=c
               
		     	Case "INNERANG"
		     		a=Val(sLinea)
               objeto(nObjeto).innerang=a

		     	Case "OUTERANG"
		     		a=Val(sLinea)
               objeto(nObjeto).outerang=a
		     		
		     	Case "DIRX"
		     		a=Val(sLinea)
               objeto(nObjeto).dirx=a
		     		
		     	Case "DIRY"
		     		a=Val(sLinea)
               objeto(nObjeto).diry=a		
                    		
		     	Case "DIRZ"
		     		a=Val(sLinea)
               objeto(nObjeto).dirz=a		

		     	Case "GHOST"
		     		a=Val(sLinea)
               objeto(nObjeto).fantasma=a	
               
		     	Case "AUTOMAP"
		     		a=Val(sLinea)
               objeto(nObjeto).automapa=a	
                    		
		     	Case "OBJECT"
               objeto(nObjeto).objeto=sLinea
               		     		
		     	Case "SCALE"
		     		a=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		b=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		c=Val(sLinea)
               objeto(nObjeto).escala(1)=a
               objeto(nObjeto).escala(2)=b
               objeto(nObjeto).escala(3)=c
               
		     	Case "ANGLE"
		     		a=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		b=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		c=Val(sLinea)
               objeto(nObjeto).angulo(1)=a
               objeto(nObjeto).angulo(2)=b
               objeto(nObjeto).angulo(3)=c
               
		     	Case "ZONESCALE"
		     		a=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		b=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		c=Val(sLinea)
               objeto(nObjeto).zonazoom(1)=a
               objeto(nObjeto).zonazoom(2)=b
               objeto(nObjeto).zonazoom(3)=c
               
		     	Case "TEXTURESCALE"
		     		a=Val(sLinea)
		     		sLinea=Mid(sLinea,InStr(sLinea,",")+1)
		     		b=Val(sLinea)
               objeto(nObjeto).texturaesc(1)=a
               objeto(nObjeto).texturaesc(2)=b
               
		     	Case Else
		     		Print "Caracteristica desconocida:";sLinea;" en ";objeto(nObjeto).tipo
		     		
		     End Select
		   wend
		End If
		Wend
		Print "Error: fichero de entidades erroneo.":Sleep:end
End Sub

' posicionamos el objeto o entidad (LUCES u OBJETOS) en su sitio, y con sus caracteristicas
Sub PosicionaObjeto()
	Dim n As Long ' temporal, para no tener que escribir nObjeto todo el rato
	n = nObjeto
	Static aaa As Integer=0
	
	Select Case objeto(nObjeto).tipo
		Case "SPOTLIGHT"
/'
			  Dim Luz As integer
			  Luz = iCreateLight( _
			    0, _
			    objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3), _
			    0.1,0.1,0.1, _
			    objeto(n).rango )

			  iLightConeAngle(Luz, objeto(n).innerang,objeto(n).outerang)
			  iLightType     (Luz, ELT_SPOT)
			  iRotateNode  (luz, _
			    objeto(n).posicion(1)+objeto(n).direccion(1), _ 
			    objeto(n).posicion(2)+objeto(n).direccion(2), _ 
			    objeto(n).posicion(3)+objeto(n).direccion(3) )
'/		  
			  Dim Lampara As Integer
			  Lampara = iCreateCube(10,FALSE)
           iPositionNode ( lampara, objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3) ) 

			    
		Case "DIRECTIONALLIGHT"
/'
			  'objeto(n).tono(1)    , objeto(n).tono(2)    ,objeto(n).tono(3)    , _
			  Dim Luz As Integer
			  Luz = iCreateLight( _
			    0, _
			    objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3), _
			    0.1,0.1,0.1, _
			    1 )

			  iLightType    (Luz , ELT_DIRECTIONAL )
			  iRotateNode   (luz, _
			    objeto(n).posicion(1)+objeto(n).dirX, _ 
			    objeto(n).posicion(2)+objeto(n).dirY, _ 
			    objeto(n).posicion(3)+objeto(n).dirZ )
'/			  			  
			  Dim Lampara As Integer
			  Lampara = iCreateCube(20,FALSE)
           iPositionNode ( lampara, objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3) )
           
		Case "POINTLIGHT"
/'
				' no usar, crea feos efectos aleatorios de brillos!!!!!!!!!
				  Dim Luz As Integer
				  Luz = iCreateLight( _
					 0, _
					 objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3), _
					 .3,.3,.3, _
					 500) 'objeto(n).rango )
				  iLightType( Luz , ELT_POINT )
				  iLightCastShadows ( Luz, TRUE )

			  'wSetLightAmbientColor  ( Luz, 1.0, 0.1, 0.7 )
           'wSetLightDiffuseColor  ( Luz, 1.0, 1.0, 0.8 )
			  'wSetLightSpecularColor ( luz, 1.0, 1.0, 1.0 )
			  'wSetLightAttenuation   ( luz, 1, 0.0, 0.0 )
'/
			   Dim Lampara As Integer
			   Lampara = iCreateSphere(20,false)
            iPositionNode ( lampara, objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3))
				iNodeColor(Lampara, objeto(nObjeto).tono(1), objeto(nObjeto).tono(2), objeto(nObjeto).tono(3),255)
				iNodeTexture( Lampara, LuzText, 0 )	
				iScaleNode( Lampara,10,10,10)
            'Print objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3):sleep
            'If objeto(n).posicion(1)= 0 Then Exit sub
			    
		Case "PORTALZONE"
			  ' son zonas de paso de una habitacion a otra (vamos, una simple puerta)
			  Dim objnodo As Integer
			  	  objnodo = iCreateCube(5,FALSE)
			  	  ' el escalado de puertas parece fallar en alguna zona....
			     iScaleNode    ( objnodo, objeto(n).zonazoom(1), objeto(n).zonazoom(2),objeto(n).zonazoom(3) )
              iPositionNode ( objnodo, objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3) )
 			     iNodeMaterialType( objnodo, IRR_EMT_TRANSPARENT_ADD_COLOR  )
 			     
		Case Else			  
			  ' si no se reconoce ninguna de las anteriores, es un objeto almacenado en su carpeta
			  Dim sObjeto As String
			  Dim objnodo As Integer
			  Dim objmalla As Integer
			  sObjeto = objeto(n).objeto
			  If sObjeto <> "" Then
		   	  'objmalla = iLoadmesh ( rutas+sObjeto )
			     'objnodo = iaddmeshtoscene( objmalla )
			     'wsetnodescale    ( objnodo, objeto(n).escala(1)/100, objeto(n).escala(2)/100,objeto(n).escala(3)/100)
              'wsetnodeposition ( objnodo, objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3) )
              'wsetnoderotation ( objnodo, objeto(n).angulo(1), objeto(n).angulo(2),objeto(n).angulo(3))
              'wAddNodeShadow   ( objnodo ) ' no hace nada ?????
              'mapcollision = wgetcollisiongroupfromcomplexmesh( objmalla, objnodo )		
              'wSetNodeMaterialFlag( objnodo, TRUE, TRUE )
			  Else
			  	  'objnodo = wAddCubeSceneNode(50)
              'wsetnodeposition ( objnodo, objeto(n).posicion(1), objeto(n).posicion(2),objeto(n).posicion(3) )
			  End If    			    

	End Select
End Sub
