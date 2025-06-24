<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:ns uri="http://www.tei-c.org/ns/1.0" prefix="tei"/>
    <sch:pattern id="TEI-rule">
        <sch:rule context="tei:TEI">
            <sch:assert test="@xml:id[matches(., 'L\d{5}')]"> @xml:id muss dem Muster 'L00000'
                entsprechen. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="back-rule">
        <sch:rule context="tei:back">
            <sch:assert test="not(descendant::*:error)"> Kein Nachfahre darf ein Element namens
                "error" enthalten. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="ref-rule">
        <sch:rule context="tei:ref">
            <sch:assert
                test="(@type = 'schnitzler-tagebuch' and matches(@target, '^(18|19)\d{2}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$')) or not(@type = 'schnitzler-tagebuch')"
                > Wenn @type="schnitzler-tagebuch", muss @target ein gültiges Datum im Format
                YYYY-MM-DD sein. </sch:assert>
            <sch:assert
                test="(@type = 'schnitzler-briefe' and matches(@target, '^L\d{5}$')) or not(@type = 'schnitzler-briefe')"
                > Wenn @type="schnitzler-briefe", muss @target dem Muster 'L00000' entsprechen.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="title-rules">
        <sch:rule context="tei:title[not(ancestor::tei:back)]">
            <sch:assert test="@level"> Das Attribut @level des tei:title muss vorhanden sein.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- correspDesc -->
    <sch:pattern id="correspDesc-rules">
        <sch:rule context="tei:correspDesc">
            <sch:assert test="not(descendant::tei:supplied)"> Kein &lt;supplied&gt;-Element erlaubt
                in correspDesc. </sch:assert>
            <sch:assert test="not(descendant::tei:correspAction[position() &gt; 1]/tei:date/@n)">
                Nur das erste correspAction darf ein date/@n haben. </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="correspAction1-rules">
        <sch:rule context="tei:correspAction[1]">
            
            <sch:assert test="descendant::tei:date/@n"> 
                Das erste correspAction muss ein date/@n enthalten
                </sch:assert>
            <sch:assert
                test="tei:date/@when or (tei:date/@notAfter and tei:date/@notBefore) or (tei:date/@from and tei:date/@to)"
                > Die erste correspAction muss ein valides tei:date Element enthalten </sch:assert>
            
        </sch:rule>
    </sch:pattern>
    
    <!-- correspContext -->
    <sch:pattern id="correspContext-rules">
        <sch:rule context="tei:correspContext">
            <sch:assert
                test="tei:ref[(@type = 'belongsToCorrespondence' and starts-with(@target, '#pmb')) or ((@type = 'withinCorrespondence' or @type = 'withinCollection') and (@subtype = 'previous_letter' or @subtype = 'next_letter'))]"
                > Es muss ein gültiges tei:ref Element mit bestimmten @type und @subtype Werten
                geben. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- correspAction -->
    <sch:pattern id="correspAction-rules">
        <sch:rule context="tei:correspAction">
            <sch:assert test="tei:persName/@ref or not(tei:persName)"> Wenn persName vorhanden ist,
                muss @ref vorhanden sein. </sch:assert>
            <sch:assert test="not(tei:date) or tei:date[not(matches(., '\n\s+\n\s+'))]"> Inhalt von
                tei:date darf keine mehrfachen Zeilenumbrüche enthalten. </sch:assert>
            <sch:assert
                test="tei:placeName[(starts-with(@ref, '#pmb') and not(@ref = '#pmb') and (string(number(substring-after(@ref, '#pmb'))) != 'NaN') and not(contains(@ref, ' ')))] or not(child::tei:placeName)"
                > Wenn placeName existiert, muss @ref gültig sein (#pmb..., keine Leerzeichen, keine mehrfachen Ortsnummern).
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- witness -->
    <sch:pattern id="witness-rules">
        <sch:rule context="tei:witness">
            <sch:assert test="tei:objectType or (number(@n) &gt; 1)"> Wenn @n = 1, muss ein
                objectType vorhanden sein. </sch:assert>
            <sch:assert
                test="(@n = 1 and descendant::tei:measure[@unit = 'zeichenanzahl']) or @n != 1">
                Wenn @n = 1, muss measure mit @unit='zeichenanzahl' enthalten sein. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- physDesc -->
    <sch:pattern id="physDesc-rules">
        <sch:rule context="tei:physDesc">
            <sch:assert test="tei:objectDesc and (tei:handDesc or tei:typeDesc)"> objectDesc ist
                erforderlich; mindestens eines von handDesc oder typeDesc muss vorhanden sein.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- handDesc -->
    <sch:pattern id="handDesc-rules">
        <sch:rule context="tei:handDesc">
            <sch:assert test="count(*) >= 1"> handDesc muss mindestens ein Kind haben. </sch:assert>
            <sch:assert test="not(count(tei:handNote) &lt; @hands)"> Anzahl der handNote darf nicht
                kleiner als @hands sein. </sch:assert>
            <sch:assert test="not(tei:handNote[not(@corresp)] and tei:handNote[2])"> Nur eine
                handNote ohne @corresp erlaubt. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- typeNote -->
    <sch:pattern id="typeNote-rules">
        <sch:rule context="tei:typeNote">
            <sch:assert test="(tei:p and @medium = 'anderes') or not(@medium = 'anderes')"> Wenn
                medium='anderes', dann muss ein p-Element vorhanden sein. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- extent -->
    <sch:pattern id="extent-rules">
        <sch:rule context="tei:extent">
            <sch:assert test="count(distinct-values(tei:measure/@unit)) = count(tei:measure)"> Alle
                @unit-Werte von measure müssen eindeutig sein. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- handNote -->
    <sch:pattern id="handNote-rules">
        <sch:rule context="tei:handNote">
            <sch:assert
                test="not(@corresp) or (starts-with(@corresp, '#pmb') and string(number(substring-after(@corresp, '#pmb'))) != 'NaN') or (@corresp = 'schreibkraft')"
                > Attribut @corresp muss entweder '#pmb...' (numerisch), 'schreibkraft' oder fehlen
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- stamp -->
    <sch:pattern id="stamp-rules">
        <sch:rule context="tei:stamp">
            <sch:assert
                test="tei:placeName[(starts-with(@ref, '#pmb') and not(@ref = '#pmb') and (string(number(substring-after(@ref, '#pmb'))) != 'NaN') or (tokenize(@ref, ' #pmb')[2]))] or not(child::tei:placeName)"
                > Wenn placeName vorhanden ist, muss @ref ein gültiger #pmb-Wert sein </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- addSpan -->
    <sch:pattern id="addSpan-content">
        <sch:rule context="tei:addSpan">
            <sch:assert test="child::* or normalize-space(.) != ''"> "addSpan" muss mindestens ein
                Kind-Element haben oder Textinhalt </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- listBibl in back -->
    <sch:pattern id="listBibl-in-back">
        <sch:rule context="tei:back/tei:listBibl">
            <sch:assert test="
                    every $c in child::*
                        satisfies local-name($c) = 'bibl'"> Im Back-Element kann
                listBibl nur Kinder vom Typ "bibl" haben </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- biblStruct -->
    <sch:pattern id="biblStruct-note">
        <sch:rule context="tei:sourceDesc[not(tei:listWit)]/tei:biblStruct[1]/tei:bibl[1]">
            <sch:assert
                test="tei:note[tei:measure[@unit = 'zeichenanzahl' and @quantity]] or not(tei:note)"
                > Wenn es keinen Archivzeugen gibt und es ein ein "note" in "biblStruct" gibt, muss es auch ein "measure" mit den
                Attributen unit="zeichenanzahl" und @quantity haben </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- analytic -->
    <sch:pattern id="analytic-title">
        <sch:rule context="tei:analytic">
            <sch:assert test="tei:title[@level = 'a']"> "analytic" muss ein Element "title" mit dem
                Attribut @level="a" haben </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- monogr -->
    <sch:pattern id="monogr-title">
        <sch:rule context="tei:monogr">
            <sch:assert test="tei:title[@level = 'm' or @level = 'j']"> "monogr" muss ein "title"
                mit dem Attribut @level="m" oder @level="j" haben </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- series -->
    <sch:pattern id="series-title">
        <sch:rule context="tei:series">
            <sch:assert test="tei:title[@level = 's']"> "series" muss ein "title" mit dem Attribut
                @level="s" haben </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- revisionDesc -->
    <sch:pattern id="revisionDesc-chronology">
        <sch:rule context="tei:revisionDesc">
            <sch:assert test="
                    every $c in tei:change[position() > 1]
                        satisfies xs:date($c/@when) ge xs:date($c/preceding-sibling::tei:change[1]/@when)"
                > Die chronologische Reihenfolge innerhalb von @when-Attributen in "change" muss
                stimmen (vom ältesten zum neuesten "change") </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- incident -->
    <sch:pattern id="incident-desc">
        <sch:rule context="tei:incident">
            <sch:assert test="tei:desc[not(@type)]"> "incident" muss ein "desc" mit dem Attribut
                @type haben </sch:assert>
            <sch:assert test="
                    every $pn in descendant::tei:placeName
                        satisfies starts-with($pn/@ref, '#pmb') and not($pn/@ref = '#pmb') and not(contains($pn/@ref, ' ')) and string(number(substring-after($pn/@ref, '#pmb'))) != 'NaN'"
                > Jedes "placeName" in incident benötigt mindestens einen Wert im Attribut @ref vom
                Typ "#pmb1234", eventuell auch mehrere @ref="#pmb1234 #pmb5678" </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- body -->
    <sch:pattern id="body-structure">
        <sch:rule context="tei:body">
            <sch:assert test="not(descendant::tei:date/@evidence)"> @evidence kann bei
                "date"-Elementen im body nicht hinzugefügt werden </sch:assert>
            <sch:assert test="not((tei:div[@n = 1])[2])"> </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- lg (line group) -->
    <sch:pattern id="lg-structure">
        <sch:rule context="tei:lg">
            <sch:assert test="
                    if (@type = 'poem') then
                        (tei:lg or tei:l)
                    else
                        if (@type = 'stanza') then
                            not(descendant::tei:lg)
                        else
                            false()"> Wenn @type="poem" muss "lg" muss als Kind "lg"
                oder "l" haben. Wenn @type="stanza", dann können nur "l" verwendet werden
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- opener -->
    <sch:pattern id="opener-rules">
        <sch:rule context="tei:opener">
            <sch:assert
                test="not(preceding-sibling::*[1]) or (not(preceding-sibling::*[2]) and preceding-sibling::tei:space[@dim = 'vertical'])"
                > Das Element opener darf nur erscheinen, wenn es kein vorheriges Geschwisterelement
                gibt oder wenn das zweite vorherige ein vertical space ist. </sch:assert>
            <sch:assert test="child::*[1]"> Das Element opener muss mindestens ein Kindelement
                besitzen. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- seg -->
    <sch:pattern id="seg-rules">
        <sch:rule context="tei:seg">
            <sch:assert
                test="(child::tei:seg[@rend = 'left'] and child::tei:seg[@rend = 'right']) or not(child::tei:seg)"
                > Wenn seg untergeordnete seg-Elemente hat, müssen diese sowohl rend='left' als auch
                rend='right' enthalten. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- dateline -->
    <sch:pattern id="dateline-rules">
        <sch:rule context="tei:dateline">
            <sch:assert
                test="(child::tei:seg[@rend = 'left'] and child::tei:seg[@rend = 'right'] and not(child::*[3])) or not(child::tei:seg)"
                > Wenn dateline zwei seg-Elemente mit rend='left' und rend='right' enthält, dürfen
                keine weiteren Kinder vorhanden sein. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- closer -->
    <sch:pattern id="closer-rules">
        <sch:rule context="tei:closer">
            <sch:assert
                test="not(child::*[1][name() = 'lb'] and text()[1][normalize-space(.) = ''])"> Wenn
                das erste Kind ein lb ist, darf der davorstehende Textknoten nicht nur aus
                Whitespace bestehen. </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- anchor -->
    <sch:pattern id="anchor-rules">
        <sch:rule context="tei:anchor">
            <sch:let name="anchortype" value="@type"/> 
            <sch:let name="anchorxmlid" value="@xml:id"/>
            <sch:assert
                test="(@type = 'commentary' and matches(@xml:id, '^((K_)(L\d{5}-\d+))$')) or not(@type = 'commentary')"
                > anchor-Elemente vom Typ commentary müssen eine xml:id mit Format
                K_L00000-0 haben. </sch:assert>
            <sch:assert
                test="(@type = 'textConst' and matches(@xml:id, '^((T_)(L\d{5}-\d+))$')) or not(@type = 'textConst')"
                > anchor-Elemente vom Typ textConst müssen eine xml:id mit Format
                T_L00000-0 haben. </sch:assert>
            <sch:assert test="((@type = 'commentary' or @type = 'textConst') and (following-sibling::tei:note[@type=$anchortype]/@corresp=$anchorxmlid)) or not((@type = 'commentary' or @type = 'textConst'))">
                Jeder "anchor" vom @typ "commentary" oder "textConst" muss ein folgendes Element "note" haben, das die @xml:id des "anchors" im @corresp hat
            </sch:assert>
            <sch:assert test="
                (following-sibling::node()[1][self::text() and normalize-space(.) = '' ] and 
                following-sibling::node()[2][self::*]) 
                or 
                (following-sibling::node()[1][self::text() and not(starts-with(., ' '))]) 
                or 
                (following-sibling::node()[1][self::*]) 
                or 
                normalize-space(.) != ''
                ">
                Auf das Element &lt;anchor/&gt; muss unmittelbar der Text oder ein Element kommen.
                Erlaubt: &lt;anchor/&gt;hier, &lt;anchor/&gt;&lt;element/&gt;, &lt;anchor/&gt; &lt;element/&gt;
                Nicht erlaubt: &lt;anchor/&gt; Text
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    <!-- normalNote -->
    <sch:pattern id="normalNote-rules">
        <sch:rule context="tei:note[@type = 'commentary' or @type = 'textConst']">
            <sch:let name="notetype" value="@type"/> 
            <sch:let name="notecorresp" value="@corresp"/>
            <sch:assert
                test="not(descendant::tei:note[@type = 'textConst' or @type = 'commentary'])">
                commentary- oder textConst-Noten dürfen keine geschachtelten Noten dieses Typs
                enthalten. </sch:assert>
            <sch:assert test="(@type = 'commentary' or @type = 'textConst') and preceding-sibling::tei:anchor[@type=$notetype]/@xml:id=$notecorresp">
                Jedes "note" vom @typ "commentary" oder "textConst" muss ein vorangehendes Element "anchor" haben, das eine zum Attribut @corresp passende @xml:id hat
            </sch:assert>
        </sch:rule>
        <sch:rule context="tei:note[@type = 'footnote']">
            <sch:assert test="starts-with(@xml:id, 'F')"> Fußnoten müssen mit 'F' beginnen. </sch:assert>
            <sch:assert test="child::tei:p"> Fußnoten müssen mindestens ein p-Element enthalten. </sch:assert>
            <sch:assert test="not(child::*[name() != 'p'])"> Fußnoten dürfen nur p-Elemente
                enthalten. </sch:assert>
        </sch:rule>
        <sch:rule context="tei:note/tei:ref">
            <sch:assert test="
                    (@subtype = 'see' or @subtype = 'cf' or @subtype = 'See' or @subtype = 'Cf' or @subtype = 'date-only' or not(@subtype)) and
                    (@type = 'schnitzler-tagebuch' or @type = 'schnitzler-briefe' or @type = 'schnitzler-lektueren' or @type = 'schnitzler-bahr' or @type = 'schnitzler-interviews')"
                > Referenzen in Notizen dürfen nur bestimmte subtype/type-Kombinationen haben.
            </sch:assert>
        </sch:rule>
        
        
        
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="tei:pb">
            <sch:assert test="following-sibling::node()[1][self::text() and normalize-space(.) = ''] and following-sibling::node()[2][self::*]
                or
                following-sibling::node()[1][self::text() and not(starts-with(., ' '))]">
                Auf das Element &lt;pb/&gt; muss unmittelbar der Text kommen. Oder ein Element. 
                Beispiele für Erlaubtes: &lt;pb/&gt;hier, &lt;pb/&gt; &lt;element/&gt;
                Beispiel für Nicht-Erlaubtes: &lt;pb/&gt; hier
            </sch:assert>
            <sch:assert test="ancestor::tei:p or ancestor::tei:seg[not(descendant::tei:seg)] or ancestor::tei:l or ancestor::tei:quote or ancestor::tei:closer or ancestor::tei:dateline  or ancestor::tei:addrLine or ancestor::tei:salute or ancestor::tei:stamp  or ancestor::tei:cell or  parent::tei:desc or parent::tei:support">
                &lt;pb/&gt; muss innerhalb eines zeilenbildenden Elements (&lt;p/&gt;, &lt;seg/&gt;, &lt;dateline/&gt;, &lt;closer, &lt;l/&gt;, &lt;addrLine/&gt;, &lt;salute/&gt;) stehen, oder, in den Metadaten, innerhalb von &lt;quote/&gt; oder &lt;stamp/&gt;
                
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- Sonderzeichen -->
    <sch:pattern id="Verbotene-Zeichen">
        <sch:rule context="text()[ancestor::tei:body or ancestor::tei:teiHeader]">
            <sch:assert test="not(matches(., '[%~]'))">
                Prozentzeichen (%)  und Tilde (~) sind durch  &lt;c rendition="#prozent"/&gt; respektive #tilde umzusetzen.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>
