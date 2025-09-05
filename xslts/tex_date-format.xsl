<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <!-- Diese Funktion hier bekommt einen Datumswert übermittelt und formatiert ihn mit Abständen zwischen den Punkten, also 3. 4. 2023 etc.,
    sollte auch auf römische Monatsangaben anwendbar sein-->
    <xsl:param name="spacy" select="'\,'" as="xs:string"/>
    <!-- Das Zeichen, das als Abstand nach dem Punkt gesetzt werden soll -->
    <xsl:function name="foo:date-translate" as="xs:string?">
        <xsl:param name="date-string" as="xs:string?"/>
        <!-- Falls von der PMB noch ISO-Daten in spitzen Klammern mitgereicht werden, diese weg -->
        <xsl:variable name="werk-datum-ohne-pmb-iso-zusatz" as="xs:string">
            <xsl:choose>
                <xsl:when test="contains($date-string, '&lt;')">
                    <xsl:value-of select="normalize-space(substring-before($date-string, '&lt;'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space($date-string)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Manchmal gelangen Zeiträume hierher, die als zwei Daten behandeln -->
        <xsl:choose>
            <xsl:when
                test="fn:normalize-space($werk-datum-ohne-pmb-iso-zusatz) = '' or empty($werk-datum-ohne-pmb-iso-zusatz)"/>
            <xsl:when test="contains($werk-datum-ohne-pmb-iso-zusatz, ' – ')">
                <xsl:variable name="datum1">
                    <xsl:analyze-string
                        select="substring-before($werk-datum-ohne-pmb-iso-zusatz, ' – ')"
                        regex="(\d{{4}})-0?(\d+)-0?(\d+)">
                        <xsl:matching-substring>
                            <xsl:variable name="datum" select="xs:date(.)" as="xs:date"/>
                            <xsl:value-of
                                select="concat(number(fn:day-from-date($datum)), '.', $spacy, number(fn:month-from-date($datum)), '.', $spacy, number(year-from-date($datum)))"
                            />
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:analyze-string select="."
                                regex="(\d{{1,2}})(\.)(\s{{0,1}})(\d{{1,2}})(\.)(\s{{0,1}})(\d{{2,4}})">
                                <xsl:matching-substring>
                                    <xsl:value-of
                                        select="concat(regex-group(1), $spacy, regex-group(4), $spacy, regex-group(7))"
                                    />
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <!--<xsl:value-of select="foo:date-repeat(., string-length(.), 1)"/>-->
                                    <xsl:value-of select="."/>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:variable name="datum2">
                    <xsl:analyze-string
                        select="substring-after($werk-datum-ohne-pmb-iso-zusatz, ' – ')"
                        regex="(\d{{4}})-0?(\d+)-0?(\d+)">
                        <xsl:matching-substring>
                            <xsl:variable name="datum" select="xs:date(.)" as="xs:date"/>
                            <xsl:value-of
                                select="concat(number(fn:day-from-date($datum)), '.', $spacy, number(fn:month-from-date($datum)), '.', $spacy, number(year-from-date($datum)))"
                            />
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:analyze-string select="."
                                regex="(\d{{1,2}})(\.)(\s{{0,1}})(\d{{1,2}})(\.)(\s{{0,1}})(\d{{2,4}})">
                                <xsl:matching-substring>
                                    <xsl:value-of
                                        select="concat(regex-group(1), $spacy, regex-group(4), $spacy, regex-group(7))"
                                    />
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:value-of select="."/>
                                    <!--<xsl:value-of select="foo:date-repeat(., string-length(.), 1)"/>-->
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when
                        test="$datum1 != $datum2 and (contains(concat($datum1, $datum2), ' ') or contains(concat($datum1, $datum2), $spacy))">
                        <xsl:value-of select="concat($datum1, ' – ', $datum2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($datum1, '–', $datum2)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- [um ...v.u.Z.?] -->
                    <xsl:when
                        test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^\[um\s(.*?)\sv.\s{0,1}u.\s{0,1}Z.\?\]$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^\[um\s(.*?)\sv.\s{{0,1}}u.\s{{0,1}}Z.\?\]$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat('{[}um ', foo:datum-analyze(substring-before(substring-after(., '[um '), '?]')), ' v.', $spacy, 'u.', $spacy, 'Z.?{]}')"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- [um ...v.u.Z.] -->
                    <xsl:when
                        test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^\[um\s(.*?)\sv.\s{0,1}u.\s{0,1}Z.\]$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^\[um\s(.*?)\sv.\s{{0,1}}u.\s{{0,1}}Z.\]$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat('{[}um ', foo:datum-analyze(substring-before(substring-after(., '[um '), '?]')), ' v.', $spacy, 'u.', $spacy, 'Z.{]}')"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- [um ...?] -->
                    <xsl:when
                        test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^\[um\s(.*?)\?\]$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^\[um\s(.*?)\?\]$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat('{[}um ', foo:datum-analyze(substring-before(substring-after(., '[um '), '?]')), '?{]}')"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- [um ...] -->
                    <xsl:when test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^\[um\s(.*?)\]$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^\[um\s(.*?)\]$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat('{[}um ', foo:datum-analyze(substring-before(substring-after(., '[um '), ']')), '{]}')"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- […?] -->
                    <xsl:when test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^\[(.*?)\?\]$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^\[(.*?)\?\]$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat('{[}', foo:datum-analyze(substring-before(substring-after(., '['), '?]')), '?{]}')"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- […] -->
                    <xsl:when test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^\[(.*?)\]$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^\[(.*?)\]$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat('{[}', foo:datum-analyze(substring-before(substring-after(., '['), ']')), '{]}')"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- um … -->
                    <xsl:when test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^um\s(.*?)$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^um\s(.*?)$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat('um ', foo:datum-analyze((substring-after(., 'um '))))"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- … v.u.Z.? -->
                    <xsl:when
                        test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^(.*?)\sv.\s{0,1}u.\s{0,1}Z.\?$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^(.*?)\sv.\s{{0,1}}u.\s{{0,1}}Z.\?$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat(foo:datum-analyze(normalize-space(substring-before(., ' v.'))), ' v.', $spacy, 'u.', $spacy, 'Z.?')"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- … v.u.Z. -->
                    <xsl:when
                        test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^(.*?)\sv.\s{0,1}u.\s{0,1}Z.$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^(.*?)\sv.\s{{0,1}}u.\s{{0,1}}Z.$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat(foo:datum-analyze(normalize-space(substring-before(., ' v.'))), ' v.', $spacy, 'u.', $spacy, 'Z.')"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <!-- … ? -->
                    <xsl:when test="fn:matches($werk-datum-ohne-pmb-iso-zusatz, '^(.*?)\?$')">
                        <xsl:analyze-string select="$werk-datum-ohne-pmb-iso-zusatz"
                            regex="^(.*?)\?$">
                            <xsl:matching-substring>
                                <xsl:value-of
                                    select="concat(foo:datum-analyze(substring-before(., '?')), '?')"
                                />
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="foo:datum-analyze($werk-datum-ohne-pmb-iso-zusatz)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="foo:datum-analyze">
        <xsl:param name="datem" as="xs:string"/>
        <xsl:variable name="datom" as="xs:string" select="fn:normalize-space($datem)"/>
        <xsl:analyze-string select="$datom" regex="^(\d{{4}})-0?(\d+)-0?(\d+)$">
            <xsl:matching-substring>
                <xsl:variable name="day">
                    <xsl:choose>
                        <xsl:when test="starts-with(regex-group(3), '0')">
                            <xsl:value-of select="substring(regex-group(3), 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(3)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="month">
                    <xsl:choose>
                        <xsl:when test="starts-with(regex-group(2), '0')">
                            <xsl:value-of select="substring(regex-group(2), 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of
                    select="concat($day, '.', $spacy, $month, '.', $spacy, number(regex-group(1)))"
                />
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="."
                    regex="^(\d{{1,2}})(\.)(&#8239;)(\d{{1,2}})(\.)(&#8239;)(\d{{2,4}})$">
                    <xsl:matching-substring>
                        <xsl:value-of
                            select="concat(regex-group(1), '.', $spacy, regex-group(4), '.', $spacy, regex-group(7))"
                        />
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:choose>
                            <xsl:when test="contains(., '&#8239;')">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:analyze-string select="."
                                    regex="^(\d{{1,2}})(\.)(\s{{0,1}})(\d{{1,2}})(\.)(\s{{0,1}})(\d{{2,4}})$">
                                    <xsl:matching-substring>
                                        <xsl:variable name="day">
                                            <xsl:choose>
                                                <xsl:when test="starts-with(regex-group(1), '0')">
                                                  <xsl:value-of
                                                  select="substring(regex-group(1), 2)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of select="regex-group(1)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:variable name="month">
                                            <xsl:choose>
                                                <xsl:when test="starts-with(regex-group(4), '0')">
                                                  <xsl:value-of
                                                  select="substring(regex-group(4), 2)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of select="regex-group(4)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:value-of
                                            select="concat($day, '.', $spacy, $month, '.', $spacy, number(regex-group(7)))"
                                        />
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:value-of select="."/>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
</xsl:stylesheet>
