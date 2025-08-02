(defun C:ASIG ( / 
	FlagASIGAutoCharSetTemp
	FlagASIGAutoLangTemp)

	(vl-catch-all-apply (function (lambda ( / )
		(ASIG_LOAD_DIALOG)
	)))
	(princ)
)
-------------------------------------------------------------------------------------------------------------------
(defun C:ED ( /
	Charset
	EnameObject
	ListVlaAttibute
	SelectionSet
	TypeObject
	VarTextEditMode
	VlaObject)

	(setq VarTextEditMode (getvar "TEXTEDITMODE"))
	(if VarTextEditMode
		(setvar "TEXTEDITMODE" 1)
	)

	(vl-catch-all-apply (function (lambda ( / )
		(or
			(and
				(setq SelectionSet (ssget "I"))
				(setq EnameObject (ssname SelectionSet 0))
			)
			(setq EnameObject (car (entsel)))
		)
		(while EnameObject
			(progn
				(setq VlaObject (vlax-ename->vla-object EnameObject))
				(setq TypeObject (vla-get-objectname VlaObject))
				(if (= TypeObject "AcDbBlockReference")
					(progn
						(vl-catch-all-apply (function (lambda ( / )
							(setq ListVlaAttibute (vlax-safearray->list (vlax-variant-value (vla-GetAttributes VlaObject))))
						)))
						(if ListVlaAttibute
							(progn
								(setq VlaObject (car ListVlaAttibute))
								(setq EnameObject (vlax-vla-object->ename VlaObject))
								(setq TypeObject (vla-get-objectname VlaObject))
							)
						)
					)
				)
				(if
					(or
						(= TypeObject "AcDbAttribute")
						(= TypeObject "AcDbMText")
						(= TypeObject "AcDbText")
						(= TypeObject "AcDbMLeader")
						(= TypeObject "AcDb3PointAngularDimension")
						(= TypeObject "AcDbAlignedDimension")
						(= TypeObject "AcDbArcDimension")
						(= TypeObject "AcDbDiametricDimension")
						(= TypeObject "AcDbFcf")
						(= TypeObject "AcDbOrdinateDimension")
						(= TypeObject "AcDbRadialDimension")
						(= TypeObject "AcDbRadialDimensionLarge")
						(= TypeObject "AcDbRotatedDimension")
					)
					(progn
						(setq Charset (ASIG_FIND_CHARSET_VLAOBJECT VlaObject))
						(command "TEXTEDIT" EnameObject)
					)
				)
				(if (= TypeObject "AcDbHatch")
					(progn
						(command "HATCHEDIT" EnameObject)
					)
				)
				(setq EnameObject nil)
				(if (= VarTextEditMode 0)
					(progn
						(or
							(and
								(setq SelectionSet (ssget "I"))
								(setq EnameObject (ssname SelectionSet 0))
							)
							(setq EnameObject (car (entsel)))
						)
					)
				)
			)
		)
	)))

	(if VarTextEditMode
		(setvar "TEXTEDITMODE" VarTextEditMode)
	)
	(princ)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_CREATE_REACTORPICKFIRSTMODIFIED ( / )
	(if (not ReactorASIGPickfirstModified)
		(setq ReactorASIGPickfirstModified
			(vlr-miscellaneous-reactor
				"ReactorASIGPickfirstModified"
				'(
					(:vlr-PickfirstModified . ASIG_CALLBACKPICKFIRSTMODIFIED)
				)
			)
		)
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_STOP_REACTORPICKFIRSTMODIFIED ( / )
	(if ReactorASIGPickfirstModified
		(progn
			(vlr-remove ReactorASIGPickfirstModified)
			(setq ReactorASIGPickfirstModified nil)
		)
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_CALLBACKPICKFIRSTMODIFIED ( ReactorObject ParameterList / 
	ListSelectionFilter
	SelectionSetTemp)

	(setq ListSelectionFilter
		(list
			(cons -4 "<OR")
			(cons 0 "DIMENSION")
			(cons 0 "INSERT")
			(cons 0 "MTEXT")
			(cons 0 "MULTILEADER")
			(cons 0 "TEXT")
			(cons 0 "TOLERANCE")
			(cons -4 "OR>")
		)
	)
	(setq SelectionSetTemp (ssget "_I" ListSelectionFilter))
	(if SelectionSetTemp
		(progn
			(setq SelectionSetASIG SelectionSetTemp)
		)
	)
	(princ)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_CREATE_REACTORCOMMANDSTART ( / )
	(if (not ReactorASIGCommandWillStart)
		(setq ReactorASIGCommandWillStart
			(vlr-command-reactor
				"ReactorASIGCommandStart"
				'(
					(:vlr-commandWillStart . ASIG_CALLBACKCOMMANDSTART)
				)
			)
		)
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_STOP_REACTORCOMMANDSTART ( / )
	(if ReactorASIGCommandWillStart
		(progn
			(vlr-remove ReactorASIGCommandWillStart)
			(setq ReactorASIGCommandWillStart nil)
		)
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_CALLBACKCOMMANDSTART ( ReactorObject ParameterList / 
	Charset
	EnameObject
	NameCommand
	NumTotal
	Num
	TypeObject
	VlaObject)

	(vl-catch-all-apply (function (lambda ( / )
		(setq NameCommand (car ParameterList))
		(if
			(or
				(= NameCommand "EATTEDIT")
				(= NameCommand "MLEADERCONTENTEDIT")
				(= NameCommand "MTEDIT")
				(= NameCommand "TEXTEDIT")
			)
			(progn
				(if SelectionSetASIG
					(progn
						(setq NumTotal (sslength SelectionSetASIG))
						(setq Num 0)
						(while (and (not Charset) (< Num NumTotal))
							(if
								(and
									(setq EnameObject (ssname SelectionSetASIG Num))
									(setq VlaObject (vlax-ename->vla-object EnameObject))
									(setq TypeObject (vla-get-objectname VlaObject))
									(or
										(= TypeObject "AcDbBlockReference")
										(= TypeObject "AcDbMText")
										(= TypeObject "AcDbText")
										(= TypeObject "AcDbMLeader")
										(= TypeObject "AcDb3PointAngularDimension")
										(= TypeObject "AcDbAlignedDimension")
										(= TypeObject "AcDbArcDimension")
										(= TypeObject "AcDbDiametricDimension")
										(= TypeObject "AcDbFcf")
										(= TypeObject "AcDbOrdinateDimension")
										(= TypeObject "AcDbRadialDimension")
										(= TypeObject "AcDbRadialDimensionLarge")
										(= TypeObject "AcDbRotatedDimension")
									)
								)
								(progn
									(setq Charset (ASIG_FIND_CHARSET_VLAOBJECT VlaObject))
								)
							)
							(setq Num (+ Num 1))
						)
					)
				)
			)
		)

		(if
			(or
				(= NameCommand "TEXT")
				(= NameCommand "DTEXT")
				(= NameCommand "MTEXT")
			)
			(progn
				(ASIG_FIND_CHARSET_NEW_TEXT)
			)
		)

		(if
			(or
				(= NameCommand "QLEADER")
			)
			(progn
				(ASIG_FIND_CHARSET_NEW_LEADER)
			)
		)

		(if
			(or
				(= NameCommand "MLEADER")
			)
			(progn
				(ASIG_FIND_CHARSET_NEW_MLEADER)
			)
		)                       
	)))
	(princ)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_FIND_CHARSET_VLAOBJECT ( VlaObject /
	Charset
	DataEnameObject
	EnameTextstyle
	ListData
	ListTypeData
	ListVlaAttibute
	NameBlock
	NameTextStyle
	TypeObject
	TypeObjectInBlock
	VlaBlock
	VlaDrawingCurrent
	VlaText
	VlaTextstyle)

	(setq TypeObject (vla-get-objectname VlaObject))
	(setq VlaDrawingCurrent (vla-get-activedocument (vlax-get-acad-object)))
	(if (= TypeObject "AcDbBlockReference")
		(progn
			(vl-catch-all-apply (function (lambda ( / )
				(setq ListVlaAttibute (vlax-safearray->list (vlax-variant-value (vla-GetAttributes VlaObject))))
			)))
			(if ListVlaAttibute
				(progn
					(setq VlaText (car ListVlaAttibute))
					(setq NameTextStyle (ASIG_VLA_GET_STYLENAME VlaText))
					(setq VlaTextstyle (vla-item (vla-get-TextStyles VlaDrawingCurrent) NameTextStyle))
					(setq Charset (nth 1 (ASIG_FIND_DATAFONT_VLATEXTSTYLE VlaTextstyle)))
				)
			)
		)
	)
	(if
		(or
			(= TypeObject "AcDbAttribute")
			(= TypeObject "AcDbMText")
			(= TypeObject "AcDbText")
		)
		(progn
			(setq VlaText VlaObject)
			(setq NameTextStyle (ASIG_VLA_GET_STYLENAME VlaText))
			(setq VlaTextstyle (vla-item (vla-get-TextStyles VlaDrawingCurrent) NameTextStyle))
			(setq Charset (nth 1 (ASIG_FIND_DATAFONT_VLATEXTSTYLE VlaTextstyle)))
		)
	)
	(if (= TypeObject "AcDbMLeader")
		(progn
			(setq DataEnameObject (entget (vlax-vla-object->ename VlaObject)))
			(setq NameTextStyle (cdr (assoc 2 (entget (cdr (assoc 340 DataEnameObject))))))
			(setq VlaTextstyle (vla-item (vla-get-TextStyles VlaDrawingCurrent) NameTextStyle))
			(setq Charset (nth 1 (ASIG_FIND_DATAFONT_VLATEXTSTYLE VlaTextstyle)))
		)
	)
	(if
		(or
			(= TypeObject "AcDb3PointAngularDimension")
			(= TypeObject "AcDbArcDimension")
			(= TypeObject "AcDbAlignedDimension")
			(= TypeObject "AcDbDiametricDimension")
			(= TypeObject "AcDbOrdinateDimension")
			(= TypeObject "AcDbRadialDimension")
			(= TypeObject "AcDbRadialDimensionLarge")
			(= TypeObject "AcDbRotatedDimension")
		)
		(progn
			(setq DataEnameObject (entget (vlax-vla-object->ename VlaObject)))
			(setq NameBlock (cdr (assoc 2 DataEnameObject)))
			(setq VlaBlock (vla-item (vla-get-Blocks VlaDrawingCurrent) NameBlock))
			(vlax-for VlaObjectInBlock VlaBlock
				(setq TypeObjectInBlock (vla-get-objectname VlaObjectInBlock))
				(if (and (not Charset) (= TypeObjectInBlock "AcDbMText"))
					(progn
						(setq VlaText VlaObjectInBlock)
						(setq NameTextStyle (ASIG_VLA_GET_STYLENAME VlaText))
						(setq VlaTextstyle (vla-item (vla-get-TextStyles VlaDrawingCurrent) NameTextStyle))
						(setq Charset (nth 1 (ASIG_FIND_DATAFONT_VLATEXTSTYLE VlaTextstyle)))
					)
				)
			)
		)
	)
	(if (= TypeObject "AcDbFcf")
		(progn
			(vla-getXdata VLaObject "ACAD" 'ListTypeData 'ListData)
			(setq ListTypeData (vlax-safearray->list ListTypeData))
			(setq ListData (vlax-safearray->list ListData))
			(setq EnameTextstyle (handent (variant-value (nth (vl-position 1005 ListTypeData) ListData))))
			(setq VlaTextstyle (vlax-ename->vla-object EnameTextstyle))
			(setq Charset (nth 1 (ASIG_FIND_DATAFONT_VLATEXTSTYLE VlaTextstyle)))
		)
	)
	(ASIG_CHANGE_CHARSET Charset)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_FIND_CHARSET_NEW_TEXT ( / 
	Charset
	NameTextStyle
	VlaDrawingCurrent
	VlaTextstyle)

	(setq VlaDrawingCurrent (vla-get-activedocument (vlax-get-acad-object)))
	(setq NameTextStyle (getvar "TEXTSTYLE"))
	(setq VlaTextstyle (vla-item (vla-get-TextStyles VlaDrawingCurrent) NameTextStyle))
	(setq Charset (nth 1 (ASIG_FIND_DATAFONT_VLATEXTSTYLE VlaTextstyle)))
	(ASIG_CHANGE_CHARSET Charset)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_FIND_CHARSET_NEW_LEADER ( / 
	Charset
	DataEnameDimstyle
	NameDimStyle
	NameTextStyle
	VlaDimStyle
	VlaDrawingCurrent
	VlaTextstyle)

	(setq VlaDrawingCurrent (vla-get-activedocument (vlax-get-acad-object)))
	(setq NameDimStyle (getvar "DIMSTYLE"))
	(setq VlaDimStyle (vla-item (vla-get-DimStyles VlaDrawingCurrent) NameDimStyle))
	(setq DataEnameDimstyle (entget (vlax-vla-object->ename VlaDimStyle)))
	(setq NameTextStyle (cdr (assoc 2 (entget (cdr (assoc 340 DataEnameDimstyle))))))
	(setq VlaTextstyle (vla-item (vla-get-TextStyles VlaDrawingCurrent) NameTextStyle))
	(setq Charset (nth 1 (ASIG_FIND_DATAFONT_VLATEXTSTYLE VlaTextstyle)))
	(ASIG_CHANGE_CHARSET Charset)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_FIND_CHARSET_NEW_MLEADER ( / 
	Charset
	DataEnameMLeaderStyle
	NameMLeaderStyle
	NameTextStyle
	VlaDrawingCurrent
	VlaMLeaderStyle
	VlaMLeaderStyles
	VlaTextstyle)

	(setq VlaDrawingCurrent (vla-get-activedocument (vlax-get-acad-object)))
	(setq NameMLeaderStyle (getvar "CMLEADERSTYLE"))
	(setq VlaMLeaderStyles (vla-item (vla-get-Dictionaries (vla-get-Database VlaDrawingCurrent)) "ACAD_MLEADERSTYLE"))
	(setq VlaMLeaderStyle (vla-item VlaMLeaderStyles NameMLeaderStyle))
	(setq DataEnameMLeaderStyle (entget (vlax-vla-object->ename VlaMLeaderStyle)))
	(setq NameTextStyle (cdr (assoc 2 (entget (cdr (assoc 342 DataEnameMLeaderStyle))))))
	(setq VlaTextstyle (vla-item (vla-get-TextStyles VlaDrawingCurrent) NameTextStyle))
	(setq Charset (nth 1 (ASIG_FIND_DATAFONT_VLATEXTSTYLE VlaTextstyle)))
	(ASIG_CHANGE_CHARSET Charset)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_CHANGE_CHARSET ( Charset /
	CharsetCurrent
	LangCurrent)

	(if Charset
		(progn
			(if (= FlagASIGAutoLang "1")
				(progn
					(setq LangCurrent (vl-registry-read "HKEY_CURRENT_USER\\Software\\Sigma\\ConfigUi\\acad" "flagLangVietGlobal"))
					(if (/= LangCurrent "true")
						(progn
							(princ (strcat "\nCh\U+1EBF \U+0111\U+1ED9: ti\U+1EBFng Vi\U+1EC7t\n"))
							(setq FlagASIGChangeLang T)
							(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoLang" "Value" "true")
						)
					)
				)
			)

			(if (= FlagASIGAutoCharSet "1")
				(progn
					(setq CharsetCurrent (vl-registry-read "HKEY_CURRENT_USER\\Software\\Sigma\\ConfigUi\\acad" "characterSet"))
					(if (/= Charset CharsetCurrent)
						(progn
							(princ (strcat "\nB\U+1EA3ng m\U+00E3: " Charset "\n"))
							(setq FlagASIGChangeCharset T)
							(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoCharset" "Value" Charset)
						)
					)
				)
			)
		)
	)
	Charset
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_CREATE_REACTORCOMMANDEND ( / )
	(if (not ReactorASIGCommandEnd)
		(setq ReactorASIGCommandEnd
			(vlr-command-reactor
				"ReactorASIGCommandEnd"
				'(
					(:vlr-unknownCommand . ASIG_CALLBACKCOMMANDEND)
					(:vlr-commandEnded . ASIG_CALLBACKCOMMANDEND)
					(:vlr-commandCancelled . ASIG_CALLBACKCOMMANDEND)
					(:vlr-commandFailed . ASIG_CALLBACKCOMMANDEND)
				)
			)
		)
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_STOP_REACTORCOMMANDEND ( / )
	(if ReactorASIGCommandEnd
		(progn
			(vlr-remove ReactorASIGCommandEnd)
			(setq ReactorASIGCommandEnd nil)
		)
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_CALLBACKCOMMANDEND ( ReactorObject ParameterList / )

	(if (= FlagASIGAutoLang "1")
		(if FlagASIGChangeLang
			(progn
				(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoLang" "Value" "Reset")
				(setq FlagASIGChangeLang nil)
			)
		)
    )

	(if (= FlagASIGAutoCharSet "1")
		(if FlagASIGChangeCharset
			(progn
				(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoCharset" "Value" "Reset")
				(setq FlagASIGChangeCharset nil)
			)
		)
    )

	(setq SelectionSetASIG nil)
	(princ)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_VLA_GET_STYLENAME ( VlaObject /
	NameStyle
	TypeObject
	DataEname
	NumCode
	NameStyle
	DataEname
	DataEnameTemp)

	(vl-catch-all-apply (function (lambda ( / )
		(setq NameStyle (vla-get-stylename VlaObject))
	)))
	(if
		(or
			(not NameStyle)
			(and
				NameStyle
				(vl-string-search "?" NameStyle)
			)
		)
		(progn
			(setq TypeObject (vla-get-ObjectName VlaObject))
			(if
				(or
					(= TypeObject "AcDb2LineAngularDimension")
					(= TypeObject "AcDb3PointAngularDimension")
					(= TypeObject "AcDbAlignedDimension")
					(= TypeObject "AcDbArcDimension")
					(= TypeObject "AcDbDiametricDimension")
					(= TypeObject "AcDbFcf")
					(= TypeObject "AcDbLeader")
					(= TypeObject "AcDbOrdinateDimension")
					(= TypeObject "AcDbRadialDimension")
					(= TypeObject "AcDbRadialDimensionLarge")
					(= TypeObject "AcDbRotatedDimension")
				)
				(setq NameStyle (cdr (assoc 3 (entget (vlax-vla-object->ename VlaObject)))))
			)
			(if
				(or
					(= TypeObject "AcDbAttributeDefinition")
					(= TypeObject "AcDbMText")
					(= TypeObject "AcDbText")
					(= TypeObject "AcDbAttribute")
				)
				(setq NameStyle (cdr (assoc 7 (entget (vlax-vla-object->ename VlaObject)))))
			)
			(if (= TypeObject "AcDbMline")
				(setq NameStyle (cdr (assoc 2 (entget (vlax-vla-object->ename VlaObject)))))
			)
			(if (= TypeObject "AcDbMLeader")
				(progn
					(setq DataEname (entget (vlax-vla-object->ename VlaObject)))
					(setq NumCode 340)
					(setq NameStyle Nil)
					(while (and (assoc NumCode DataEname) (not NameStyle))
						(setq DataEnameTemp (entget (cdr (assoc NumCode DataEname))))
						(if
							(= (cdr (assoc 0 DataEnameTemp)) "MLEADERSTYLE")
							(setq NameStyle (ASIG_VLA_GET_NAME (vlax-ename->vla-object (cdr (assoc NumCode DataEname)))))
						)
						(setq DataEname (vl-remove (assoc NumCode DataEname) DataEname))
					)
				)
			)
			(if (= TypeObject "AcDbTable")
				(progn
					(setq DataEname (entget (vlax-vla-object->ename VlaObject)))
					(setq NumCode 342)
					(setq NameStyle Nil)
					(while (and (assoc NumCode DataEname) (not NameStyle))
						(setq DataEnameTemp (entget (cdr (assoc NumCode DataEname))))
						(if
							(= (cdr (assoc 0 DataEnameTemp)) "TABLESTYLE")
							(setq NameStyle (ASIG_VLA_GET_NAME (vlax-ename->vla-object (cdr (assoc NumCode DataEname)))))
						)
						(setq CharSet (car (vl-remove (assoc NumCode DataEname) DataEname)))
					)
				)
			)
		)
	)
	NameStyle
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_VLA_GET_NAME ( VlaStyle /
	NameStyle
	NameStyleTemp
	TypeObject
	DataEnameTemp)

	(vl-catch-all-apply (function (lambda ( / )
		(setq NameStyle (vla-get-name VlaStyle))
	)))
	(if
		(or
			(not NameStyle)
			(and
				NameStyle
				(vl-string-search "?" NameStyle)
			)
		)
		(progn
			(setq TypeObject (vla-get-ObjectName VlaStyle))
			(if
				(or
					(= TypeObject "AcDbBlockReference")
					(= TypeObject "AcDbBlockTableRecord")
					(= TypeObject "AcDbDimStyleTableRecord")
					(= TypeObject "AcDbLayerTableRecord")
					(= TypeObject "AcDbLinetypeTableRecord")
					(= TypeObject "AcDbTextStyleTableRecord")
					(= TypeObject "AcDbUCSTableRecord")
					(= TypeObject "AcDbMlineStyle")
				)
				(setq NameStyle (cdr (assoc 2 (entget (vlax-vla-object->ename VlaStyle)))))
			)
			(if
				(or
					(= TypeObject "AcDbLayout")
					(= TypeObject "AcDbMaterial")
					(= TypeObject "AcDbMLeaderStyle")
					(= TypeObject "AcDbPlotSettings")
					(= TypeObject "AcDbTableStyle")
					(= TypeObject "AcDbVisualStyle")
					(= TypeObject "AcDbDetailViewStyle")
					(= TypeObject "AcDbSectionViewStyle")
					(= TypeObject "AcDbPlaceHolder")
					(= TypeObject "AcDbXrecord")
					(= TypeObject "AcDbDictionary")
					(= TypeObject "AcDbRasterImageDef")
					(= TypeObject "AcDbDwfDefinition")
					(= TypeObject "AcDbPdfDefinition")
					(= TypeObject "AcDbDgnDefinition")
					(= TypeObject "AcDbPointCloudDefEx")
					(= TypeObject "AcDbNavisworksModelDef")
				)
				(progn
					(setq NameStyle (cdr (assoc 3 (member (cons 350 (vlax-vla-object->ename VlaStyle)) (reverse (entget (vlax-vla-object->ename (vla-ObjectIdToObject (vla-get-document VlaStyle) (vla-get-ownerid VlaStyle)))))))))
					(if (not NameStyle)
						(setq NameStyle (cdr (assoc 3 (member (cons 360 (vlax-vla-object->ename VlaStyle)) (reverse (entget (vlax-vla-object->ename (vla-ObjectIdToObject (vla-get-document VlaStyle) (vla-get-ownerid VlaStyle)))))))))
					)
				)
			)
			(if
				(or
					(= TypeObject "AcDbRasterImage")
					(= TypeObject "AcDbDwfReference")
					(= TypeObject "AcDbPdfReference")
					(= TypeObject "AcDbDgnReference")
					(= TypeObject "AcDbPointCloudEx")
					(= TypeObject "AcDbNavisworksModel")
				)
				(setq NameStyle (ASIG_VLA_GET_NAME (vlax-ename->vla-object (cdr (assoc 340 (entget (vlax-vla-object->ename VlaStyle)))))))

			)
		)
	)
	(if (not NameStyle)
		(vl-catch-all-apply (function (lambda ( / )
			(setq NameStyle (vla-get-name VlaStyle))
		)))
	)
	NameStyle
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_FIND_DATAFONT_VLATEXTSTYLE ( VlaTextstyle /
	Charset
	FontBold
	FontItalic
	NameFont
	PathFont
	PitchAndFamily
	TypeCode)

	(vla-GetFont VlaTextStyle 'NameFont 'FontBold 'FontItalic 'Charset 'PitchAndFamily)
	(setq TypeCode (ASIG_FIND_TYPECODE_NAMEFONT NameFont))
	(if (not TypeCode)
		(progn
			(setq PathFont (vla-get-fontFile VlaTextStyle))
			(setq NameFont (vl-filename-base PathFont))
			(setq TypeCode (ASIG_FIND_TYPECODE_NAMEFONT NameFont))
		)
	)
	(list NameFont TypeCode)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_FIND_TYPECODE_NAMEFONT ( NameFont / TypeCode)

	(cond
		(
			(= (strcase (substr NameFont 1 3)) "VNI")
			(setq TypeCode "VNI Windows")
		)
		(
			(or
				(= (strcase (substr NameFont 1 3)) ".VN")
				(= (strcase (substr NameFont 1 2)) "VN")
			)
			(setq TypeCode "TCVN3 (ABC)")
		)
		(
			(/= NameFont "")
			(setq TypeCode "Unicode")
		)
	)
	TypeCode
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_LOAD_DIALOG ( /
	End_Main_DCL
	Main_DCL)

	(ASIG_MAKE_FILE_DCL)
	(setq Main_DCL (load_dialog "Auto Sigma.dcl"))
	(new_dialog "AutoSigma" Main_DCL)
	(ASIG_SET_TILE_DECORATION 1)
	(ASIG_SET_TILE_FLAGASIGAUTOLANG)
	(ASIG_SET_TILE_FLAGASIGAUTOCHARSET)
  
	(action_tile "Tile_FlagASIGAutoLang"	"(ASIG_GET_TILE_FLAGASIGAUTOLANG)")
	(action_tile "Tile_FlagASIGAutoCharSet"	"(ASIG_GET_TILE_FLAGASIGAUTOCHARSET)")
	(action_tile "Tile_About"				"(ASIG_ABOUT_PROGRAM)")

	(setq End_Main_DCL (start_dialog))
	(cond
		(
			(= End_Main_DCL 0)
			(unload_dialog Main_DCL)
		)
		(
			(= End_Main_DCL 1)
			(setq FlagASIGAutoLang FlagASIGAutoLangTemp)
			(setq FlagASIGAutoCharSet FlagASIGAutoCharSetTemp)
			(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoLang" FlagASIGAutoLang)
			(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoCharSet" FlagASIGAutoCharSet)

			(if
				(or
					(= FlagASIGAutoLang "1")
					(= FlagASIGAutoCharSet "1")
				)
				(progn
					(ASIG_CREATE_REACTORPICKFIRSTMODIFIED)
					(ASIG_CREATE_REACTORCOMMANDSTART)
					(ASIG_CREATE_REACTORCOMMANDEND)
				)
				(progn
					(ASIG_STOP_REACTORPICKFIRSTMODIFIED)
					(ASIG_STOP_REACTORCOMMANDSTART)
					(ASIG_STOP_REACTORCOMMANDEND)
				)
			)
			(unload_dialog Main_DCL)
		)
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_SET_TILE_FLAGASIGAUTOLANG ( / )
	(if
		(not
			(and
				FlagASIGAutoLang
				(or
					(= FlagASIGAutoLang "0")
					(= FlagASIGAutoLang "1")
				)
			)
		)
		(progn
			(setq FlagASIGAutoLang (vl-registry-read "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoLang"))
		)
	)

	(if
		(not
			(and
				FlagASIGAutoLang
				(or
					(= FlagASIGAutoLang "0")
					(= FlagASIGAutoLang "1")
				)
			)
		)
		(progn
			(setq FlagASIGAutoLang "1")
			(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoLang" FlagASIGAutoLang)
		)
	)
	(setq FlagASIGAutoLangTemp FlagASIGAutoLang)
	(set_tile "Tile_FlagASIGAutoLang" FlagASIGAutoLang)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_GET_TILE_FLAGASIGAUTOLANG ( / )
	(setq FlagASIGAutoLangTemp (get_tile "Tile_FlagASIGAutoLang"))
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_SET_TILE_FLAGASIGAUTOCHARSET ( / )
	(if
		(not
			(and
				FlagASIGAutoCharSet
				(or
					(= FlagASIGAutoCharSet "0")
					(= FlagASIGAutoCharSet "1")
				)
			)
		)
		(progn
			(setq FlagASIGAutoCharSet (vl-registry-read "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoCharSet"))
		)
	)

	(if
		(not
			(and
				FlagASIGAutoCharSet
				(or
					(= FlagASIGAutoCharSet "0")
					(= FlagASIGAutoCharSet "1")
				)
			)
		)
		(progn
			(setq FlagASIGAutoCharSet "1")
			(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoCharSet" FlagASIGAutoCharSet)
		)
	)
	(setq FlagASIGAutoCharSetTemp FlagASIGAutoCharSet)
	(set_tile "Tile_FlagASIGAutoCharSet" FlagASIGAutoCharSet)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_GET_TILE_FLAGASIGAUTOCHARSET ( / )
	(setq FlagASIGAutoCharSetTemp (get_tile "Tile_FlagASIGAutoCharSet"))
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_MAKE_FILE_DCL ( /
	Num
	DclFile
	DirectoryDes)

	(setq DirectoryDes (strcat (getvar "roamablerootprefix") "Support"))
	(setq DclFile (open (strcat DirectoryDes "\\Auto Sigma.dcl") "w"))
	(write-line "///------------------------------------------------------------------------" DclFile)
	(write-line "///		Auto Sigma.dcl" DclFile)
	(write-line "AutoSigma:dialog{" DclFile)
	(write-line (strcat "label = \"Auto Sigma\";") DclFile)
	(write-line "	spacer_1;" dclfile)

	(write-line "	:toggle{" DclFile)
	(write-line "	label = \"T\U+1EF1 \U+0111\U+1ED9ng chuy\U+1EC3n qua ch\U+1EBF \U+0111\U+1ED9 ti\U+1EBFng Vi\U+1EC7t khi t\U+1EA1o, s\U+1EEDa c\U+00E1c \U+0111\U+1ED5i t\U+01B0\U+1EE3ng text\";" DclFile)
	(write-line "	key = \"Tile_FlagASIGAutoLang\";" DclFile)
	(write-line "	}" DclFile)

	(write-line "	:toggle{" DclFile)
	(write-line "	label = \"T\U+1EF1 \U+0111\U+1ED9ng chuy\U+1EC3n \U+0111\U+1ED5i b\U+1EA3ng m\U+00E3 ph\U+00F9 h\U+1EE3p khi t\U+1EA1o, s\U+1EEDa c\U+00E1c \U+0111\U+1ED5i t\U+01B0\U+1EE3ng text\";" DclFile)
	(write-line "	key = \"Tile_FlagASIGAutoCharSet\";" DclFile)
	(write-line "	}" DclFile)

	(write-line "	:text{" DclFile)
	(write-line "	key = \"sep0\";" DclFile)
	(write-line "	}" DclFile)

	(write-line "	:row{" DclFile)
	(write-line "		:button{" DclFile)
	(write-line "		label = \"\U+0110\U+1ED3n&g \U+00FD\";" DclFile)
	(write-line "		key = \"Tile_Ok\";" DclFile)
	(write-line "		is_default = true;" DclFile)
	(write-line "		width = 18;" DclFile)
	(write-line "		}" DclFile)

	(write-line "		:button{" DclFile)
	(write-line "		key = \"Tile_Cancel\";" DclFile)
	(write-line "		label = \"&H\U+1EE7y\";" DclFile)
	(write-line "		is_cancel = true;" DclFile)
	(write-line "		width = 18;" DclFile)
	(write-line "		}" DclFile)

	(write-line "		:button{" DclFile)
	(write-line "		key = \"Tile_About\";" DclFile)
	(write-line "		label = \"&Li\U+00EAn h\U+1EC7 ...\";" DclFile)
	(write-line "		width = 18;" DclFile)
	(write-line "		}" DclFile)
	(write-line "	}" DclFile)
	(write-line "}" DclFile)

	(write-line "/// About Dialog Box ----------------------------------------------" DclFile)
	(write-line "AutoSigmaAbout:dialog{" DclFile)
	(write-line "label = \"Th\U+00F4ng tin\";" DclFile)
	(write-line "	:boxed_column{" DclFile)
	(write-line "		:text{" DclFile)
	(write-line "		label = \"Auto Sigma\";" DclFile)
	(write-line "		}" DclFile)
	(write-line "		:text{" DclFile)
	(write-line "		key = \"sep0\";" DclFile)
	(write-line "		}" DclFile)
	(write-line "		:row{" DclFile)
	(write-line "			:column{" DclFile)
	(write-line "				:text{" DclFile)
	(write-line "				label = \"     T\U+00E1c gi\U+1EA3\";" DclFile)
	(write-line "				}" DclFile)
	(write-line "				:text{" DclFile)
	(write-line "				label = \"     \U+0110\U+1EBFn t\U+1EEB\";" DclFile)
	(write-line "				}" DclFile)
	(write-line "				:text{" DclFile)
	(write-line "				label = \"     Th\U+01B0 \U+0111i\U+1EC7n t\U+1EED\";" DclFile)
	(write-line "				}" DclFile)
	(write-line "				:text{" DclFile)
	(write-line "				label = \"     \U+0110i\U+1EC7n tho\U+1EA1i\";" DclFile)
	(write-line "				}" DclFile)
	(write-line "			}" DclFile)
	(write-line "			:column{" DclFile)
	(write-line "				:text{" DclFile)
	(write-line "				label = \"     : Ph\U+1EA1m Ho\U+00E0ng Nh\U+1EADt\";" DclFile)
	(write-line "				}" DclFile)
	(write-line "				:text{" DclFile)
	(write-line "				label = \"     : TP H\U+1ED3 Ch\U+00ED Minh - Vi\U+1EC7t Nam\";" DclFile)
	(write-line "				}" DclFile)
	(write-line "				:text{" DclFile)
	(write-line "				label = \"     : phamhoangnhat@gmail.com\";" DclFile)
	(write-line "				}" DclFile)
	(write-line "				:text{" DclFile)
	(write-line "				label = \"     : +84 933 648 160\";" DclFile)
	(write-line "				}" DclFile)
	(write-line "			}" DclFile)
	(write-line "		}" DclFile)
	(write-line "		:text{" DclFile)
	(write-line "		key = \"sep1\";" DclFile)
	(write-line "		}" DclFile)
	(write-line "		:paragraph{" DclFile)
	(write-line "		width = 55;" DclFile)
	(write-line "			:text_part{" DclFile)
	(write-line "				value = \"M\U+1ECDi \U+00FD ki\U+1EBFn \U+0111\U+00F3ng g\U+00F3p vui l\U+00F2ng g\U+1EEDi email \U+0111\U+1EBFn phamhoangnhat@gmail.com\";" DclFile)
	(write-line "			}" DclFile)
	(write-line "			:text_part{" DclFile)
	(write-line "				value = \"C\U+1EA3m \U+01A1n b\U+1EA1n \U+0111\U+00E3 s\U+1EED d\U+1EE5ng v\U+00E0 h\U+1ED7 tr\U+1EE3\";" DclFile)
	(write-line "			}" DclFile)
	(write-line "		}" DclFile)
	(write-line "	}" DclFile)
	(write-line "	:button{" DclFile)
	(write-line "	label = \"&OK\";" DclFile)
	(write-line "	key = \"OkAbout\";" DclFile)
	(write-line "	is_default = true;" DclFile)
	(write-line "	is_cancel = true;" DclFile)
	(write-line "	width = 15;" DclFile)
	(write-line "	}" DclFile)
	(write-line "}" DclFile)

	(close DclFile)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_ABOUT_PROGRAM (/
	About_DCL
	About_End_Dialog)

	(setq About_DCL (load_dialog "Auto Sigma.dcl"))
	(new_dialog "AutoSigmaAbout" About_DCL)
	(ASIG_SET_TILE_OF_SEP "sep1")
	(ASIG_SET_TILE_OF_SEP "sep2")
	(action_tile "OkAbout" "(done_dialog 0)")
	(setq About_End_Dialog (start_dialog))
	(unload_dialog About_DCL)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_SET_TILE_DECORATION ( NumTotal / Num )
	(setq Num 0)
	(repeat NumTotal
		(ASIG_SET_TILE_OF_SEP (strcat "sep" (itoa Num)))
		(setq Num (+ Num 1))
	)
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_SET_TILE_OF_SEP ( Tile / )
	(set_tile Tile "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	(mode_tile Tile 1)                                                    
)
-------------------------------------------------------------------------------------------------------------------
(defun ASIG_STARTUP ( / )
	(vl-load-com)
	(vl-catch-all-apply (function (lambda ( / )
		(acet-load-expresstools)
	)))

	(if
		(not
			(and
				FlagASIGAutoLang
				(or
					(= FlagASIGAutoLang "0")
					(= FlagASIGAutoLang "1")
				)
			)
		)
		(progn
			(setq FlagASIGAutoLang (vl-registry-read "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoLang"))
		)
	)

	(if
		(not
			(and
				FlagASIGAutoLang
				(or
					(= FlagASIGAutoLang "0")
					(= FlagASIGAutoLang "1")
				)
			)
		)
		(progn
			(setq FlagASIGAutoLang "1")
			(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoLang" FlagASIGAutoLang)
		)
	)

	(if
		(not
			(and
				FlagASIGAutoCharSet
				(or
					(= FlagASIGAutoCharSet "0")
					(= FlagASIGAutoCharSet "1")
				)
			)
		)
		(progn
			(setq FlagASIGAutoCharSet (vl-registry-read "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoCharSet"))
		)
	)

	(if
		(not
			(and
				FlagASIGAutoCharSet
				(or
					(= FlagASIGAutoCharSet "0")
					(= FlagASIGAutoCharSet "1")
				)
			)
		)
		(progn
			(setq FlagASIGAutoCharSet "1")
			(vl-registry-write "HKEY_CURRENT_USER\\Software\\Sigma\\AutoSigma" "FlagASIGAutoCharSet" FlagASIGAutoCharSet)
		)
	)

	(if
		(or
			(= FlagASIGAutoLang "1")
			(= FlagASIGAutoCharSet "1")
		)
		(progn
			(ASIG_CREATE_REACTORPICKFIRSTMODIFIED)
			(ASIG_CREATE_REACTORCOMMANDSTART)
			(ASIG_CREATE_REACTORCOMMANDEND)
		)
		(progn
			(ASIG_STOP_REACTORPICKFIRSTMODIFIED)
			(ASIG_STOP_REACTORCOMMANDSTART)
			(ASIG_STOP_REACTORCOMMANDEND)
		)
	)
)
-------------------------------------------------------------------------------------------------------------------
(ASIG_STARTUP)

