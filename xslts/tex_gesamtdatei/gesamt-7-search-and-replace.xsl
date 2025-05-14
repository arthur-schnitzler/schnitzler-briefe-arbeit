<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:so="stackoverflow example"
                version="2.0"
                exclude-result-prefixes="so">
    <xsl:output indent="no" method="text"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="list">
        <words>
            <word>
                <search> / </search>
                <replace>{\slashislash}</replace>
            </word>
            <word>
                <search>.–</search>
                <replace>{\dotdash}</replace>
            </word>
            <word>
                <search>,–</search>
                <replace>{\commadash}</replace>
            </word>
            <word>
                <search>;–</search>
                <replace>{\semicolondash}</replace>
            </word>
            <word>
                <search>!–</search>
                <replace>{\excdash}</replace>
            </word>
            <word>
                <search>1 Bl.</search>
                <replace>1&#160;Bl.</replace>
            </word>
            <word>
                <search>2 Bl.</search>
                <replace>2&#160;Bl.</replace>
            </word>
            <word>
                <search>3 Bl.</search>
                <replace>3&#160;Bl.</replace>
            </word>
            <word>
                <search>4 Bl.</search>
                <replace>4&#160;Bl.</replace>
            </word>
            <word>
                <search>5 Bl.</search>
                <replace>5&#160;Bl.</replace>
            </word>
            <word>
                <search>6 Bl.</search>
                <replace>6&#160;Bl.</replace>
            </word>
            <word>
                <search>7 Bl.</search>
                <replace>7&#160;Bl.</replace>
            </word>
            <word>
                <search>8 Bl.</search>
                <replace>8&#160;Bl.</replace>
            </word>
            <word>
                <search>9 Bl.</search>
                <replace>9&#160;Bl.</replace>
            </word>
            <word>
                <search>0 Bl.</search>
                <replace>0&#160;Bl.</replace>
            </word>
           
        </words>
    </xsl:param>
    
    <xsl:function name="so:escapeRegex">
        <xsl:param name="regex"/>
        <xsl:analyze-string select="$regex" regex="\.|\{{">
            <xsl:matching-substring>
                <xsl:value-of select="concat('\',.)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:template match="@*|*|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:variable name="search"
                    select="so:escapeRegex(concat('(',string-join($list/words/word/search,'|'),')'))"/>
        <xsl:analyze-string select="." regex="{$search}">
            <xsl:matching-substring>
                <xsl:message>"<xsl:value-of select="."/>" matched <xsl:value-of select="$search"/>
            </xsl:message>
                <xsl:value-of select="$list/words/word[search=current()]/replace"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
</xsl:stylesheet>
