<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">
    
    <xsl:output method="xml" encoding="utf-8" indent="no"/>
    
    
   <!--     Identity template : copy all text nodes, elements and attributes   
-->    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="date[contains(text(),'?')]">
        <date_low>
            <xsl:apply-templates select="@*|node()"/>
        </date_low>
    </xsl:template>
    
    
  <!--  
    <xsl:template match="person[persName[1]/forename[ends-with(text(), ')')]]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <persName type="alt" subtype="Rufname">
                <xsl:value-of select="substring-before(substring-after(persName[1]/forename, '('),')')"/>
            </persName>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="forename[ends-with(text(), ')')]">
        <xsl:copy>
            <xsl:value-of select="substring-before(text(), ' (')"/>
        </xsl:copy>
    </xsl:template>-->
    
   <!-- <xsl:template match="persName[preceding-sibling::persName and not(@type) and not(@subtype) and descendant::*[not(@type) and not(@subtype)]]">
        <xsl:copy>
            <xsl:attribute name="type">alt</xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    -->
    
    <!--<xsl:template match="person/persName[@type='alt']/forename[ancestor::person/persName[1]/forename = current()]"/>-->
       
    <!--<xsl:template match="persName[not(position() = 1) and not(child::*[2]) and not(@subtype) and child::*/@subtype]">
        <xsl:copy>
            <xsl:attribute name="subtype">
            <xsl:value-of select="child::*[1]/@subtype"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>-->
    
    
    <xsl:template match="surname[contains(text(), '[')]">
        <xsl:copy>
            <xsl:attribute name="cert">low</xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="forename[contains(text(), '[')]">
        <xsl:copy>
            <xsl:attribute name="cert">low</xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
   
  <!--<xsl:template match="persName/forename[contains(text(), ', ')]">
      <xsl:variable name="vorname" select="tokenize(text(), ', ')[1]"/> 
      <xsl:variable name="zwei" select="tokenize(text(), ', ')[2]"/>
      <xsl:variable name="drei" select="tokenize(text(), ', ')[3]"/>
      <forename>
          <xsl:value-of select="$vorname"/>
      </forename>
      <surname type="alt">
          <xsl:value-of select="$zwei"/>
      </surname>
      <surname type="alt">
          <xsl:value-of select="$drei"/>
      </surname>-->
      
    <!--  <xsl:choose>
            <xsl:when test="starts-with(.,'geb.')">
                <xsl:variable name="name" select="substring-after(., 'geb. ')"/>
                    <xsl:choose>
                        <xsl:when test="contains($name,' ')">
                            <forename type="given">
                                <xsl:value-of select="substring-before($name, ' ')"/>
                            </forename>
                            <surname type="birth">
                                <xsl:value-of select="substring-after($name, ' ')"/>
                            </surname>
                        </xsl:when>
                        <xsl:otherwise>
                            <surname type="birth">
                            <xsl:value-of select="substring-after(., 'geb. ')"/>
                            </surname>
                        </xsl:otherwise>
                    </xsl:choose>
            </xsl:when>
            <xsl:when test="starts-with(.,'gen.')">
                    <forename type='abb'>
                        <xsl:value-of select="substring-after(., 'gen. ')"/>
                    </forename>
            </xsl:when>
            <xsl:when test="starts-with(.,'verh.')">
                    <surname type='married'>
                        <xsl:value-of select="substring-after(., 'verh. ')"/>
                    </surname>
            </xsl:when>
            <xsl:when test="starts-with(.,'auch ')">
                <persName type='changed'>
                    <xsl:value-of select="substring-after(., 'auch ')"/>
                </persName>
            </xsl:when>
            <xsl:when test="starts-with(.,'verw. ')">
                    <sureName type='widowed'>
                    <xsl:value-of select="substring-after(., 'verw. ')"/>
                    </sureName>
            </xsl:when>
            <xsl:when test="starts-with(.,'gesch. ')">
                <surename type='divorced'>
                    <xsl:value-of select="substring-after(., 'gesch. ')"/>
                </surename>
            </xsl:when>
            <xsl:when test="starts-with(.,'Pseud. ')">
                <persName type='pseudonym'>
                    <xsl:value-of select="substring-after(., 'Pseud. ')"/>
                </persName>
            </xsl:when>
            <xsl:when test="starts-with(.,'adopt. ')">
                <sureName type='adopted'>
                    <xsl:value-of select="substring-after(., 'adopt. ')"/>
                </sureName>
            </xsl:when>
            <xsl:otherwise>
                <zusatz>
                <xsl:apply-templates/>
                </zusatz>
            </xsl:otherwise>
        </xsl:choose>-->
  <!--  </xsl:template>-->
    
   <!-- <xsl:template match="surname[starts-with(text(), 'geb. ')]">
        <surname type="alt">
        <xsl:attribute name="subtype">Geboren</xsl:attribute>
        <xsl:value-of select="substring-after(text(), 'geb. ')"/>
        </surname>
    </xsl:template>
    
    <xsl:template match="surname[starts-with(text(), 'verw. ')]">
        <surname type="alt">
        <xsl:attribute name="subtype">Verwitwet</xsl:attribute>
        <xsl:value-of select="substring-after(text(), 'verw. ')"/>
        </surname>
    </xsl:template>
    
    <xsl:template match="surname[starts-with(text(), 'verh. ')]">
        <surname type="alt">
        <xsl:attribute name="subtype">Ehename</xsl:attribute>
        <xsl:value-of select="substring-after(text(), 'verh. ')"/>
        </surname>
    </xsl:template>
    
    <xsl:template match="surname[starts-with(text(), 'gesch. ')]">
        <surname type="alt">
        <xsl:attribute name="subtype">Geschieden</xsl:attribute>
        <xsl:value-of select="substring-after(text(), 'gesch. ')"/>
        </surname>
    </xsl:template>-->
  
   <!-- <xsl:template match="person">
        <person>
            <xsl:apply-templates/>
            <xsl:if test="not(child::sex)"><xsl:choose>
                <xsl:when test="ends-with(occupation[2]/text(), 'in')">
                    <sex>f</sex>
                </xsl:when>
                <xsl:when test="ends-with(occupation[2]/text(), 'er')">
                    <sex>m</sex>
                </xsl:when>
            </xsl:choose></xsl:if>
        </person>
    </xsl:template>
    -->
    
    
   
</xsl:stylesheet>
