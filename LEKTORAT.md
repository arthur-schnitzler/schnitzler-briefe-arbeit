# Lektorat der Briefe in `editions/*.xml`

Stand: 6. 7. 2026 · Bearbeitung: Claude (maschinelle Prüfung + kritische Lektüre)

**Vorgehen:** Alle 4366 Dateien wurden maschinell geprüft (Wortdopplungen, Rechtschreibung
der Herausgeberkommentare via aspell de_AT, unpaarige Klammern und Anführungszeichen,
alte Orthografie im Herausgebertext). Zusätzlich werden die Brieftexte samt Kommentaren
fortlaufend kritisch gelesen; Befunde daraus stehen in Abschnitt 4. Die `back`-Elemente
wurden vereinbarungsgemäß ignoriert. Zitate und historische Schreibweisen im Brieftext
(Lang-ſ, »daß«, »Litteratur« usw.) gelten nicht als Fehler.

---

## 1. Verifizierte Fehler in Herausgeberkommentaren (`note type="commentary"`)

Tippfehler im Herausgebertext, jeweils mit Korrekturvorschlag. Alle Belege wurden am
Roh-XML verifiziert und stehen außerhalb von Zitaten.

| Datei | Fehler | Korrektur | Kontext |
|---|---|---|---|
| L01345.xml | »Uraufführung von von Der Meister« | ein »von« streichen | Wortdopplung |
| L01455.xml | »ob es eine eine Vorauszahlung« | ein »eine« streichen | Wortdopplung |
| L01912.xml | »Suizid zu wiederlegen« | widerlegen | |
| L02621.xml | »freundlich abgelehnt hattee« | hatte | |
| L02629.xml | »nicht identifizert« | identifiziert | |
| L02638.xml | »auf Februar 1897 datuert« | datiert | |
| L02679.xml | »verteten wir die Ansicht« | vertreten/vertraten | |
| L02877.xml | »vebrachte den Sommer« | verbrachte | |
| L02916.xml | »das am am 11. 5. 1900 Onkel Toni gab« | ein »am« streichen | Wortdopplung (im Roh-XML, kein Ref-Artefakt) |
| L02967.xml | »der wöchentlich erscheinenenden« | erscheinenden | |
| L02974.xml | »spielte vom 6. 5. 1902 bis zum zum 5. 6. 1902« | ein »zum« streichen | Wortdopplung |
| L03039.xml | »die trotz des Tagebuchs exisitieren« | existieren | |
| L03147.xml | »dürfte nicht M. J. Mayer gemeibt sein« | gemeint | |
| L03295.xml | »eine mehrtätige gemeinsame Wanderung« | mehrtägige | |
| L03339.xml | »Die Depesche lautetete« | lautete | |
| L03527.xml | »das von Ludwig Grillich angefertige Porträtfoto« | angefertigte | |
| L03649.xml | »der Montag innnerhalb der […] Tage« | innerhalb | |
| L03774.xml | »ihre Ehe […] annulieren« | annullieren | |
| L03837.xml | »eine postitive Neubewertung« | positive | |
| L03843.xml | »die allerings in der Druckfassung« | allerdings | |
| L03846.xml | »das franzöische Kabinett« | französische | |
| L03851.xml | »die nicht nur postitive Töne enthielt« | positive | |
| L03854.xml | »eine postive Besprechung« | positive | |
| L03867.xml | »zur Aussprache und zulgleich weiterem Befremden« | zugleich | |
| L03934.xml | »Beschreibungen […] anuwenden« | anzuwenden | |
| L03947.xml | »Comédie en en act« | ein »en« streichen; ggf. »en un acte«? | auch L03960.xml, gleiche Bibliografie |
| L03948.xml | »die urspünglich vereinbarte Frist« | ursprünglich | |
| L03960.xml | »Die Die Premiere von Au Perroquet Vert« | ein »Die« streichen | Wortdopplung |
| L03965.xml | »keine Aufführung des des ›Tapferen Cassian‹« | ein »des« streichen | Wortdopplung |
| L04006.xml | »mit am Tag zuvor vorangegangner Generalprobe« | vorangegangener | |
| L04008.xml | »um ihr zu kondilieren« | kondolieren | |
| L04133.xml | »besuchte die die Aufführung von Cyrano« | ein »die« streichen | Wortdopplung |
| L04158.xml | »Der Plan wurde nicht verwirkklicht« | verwirklicht (zudem fehlt der Schlusspunkt) | |
| L04231.xml | »östrreichisch veraltet: ausgeschlachtet« | österreichisch | |
| L04313.xml | »Das Tal des Lebens (von Max Dreyer) und und Der Meister« | ein »und« streichen | Wortdopplung |
| L04318.xml | »lässt sich folgerndermaßen eingrenzen« | folgendermaßen | |
| L04318.xml | »nahzu« | nahezu | |
| L04323.xml | »der weggewofene Ring« | weggeworfene | |
| L03830.xml | »wäre im Stande gewesen gewesen« | ein »gewesen« streichen | Wortdopplung |
| L03198.xml | »Goldmann schrieb Beer-Hofmannn noch am selben Tag« | Beer-Hofmann | dreifaches n |

### Alte Rechtschreibung im Herausgebertext (Kommentare sind sonst durchgehend in neuer Orthografie)

| Datei | Fundstelle | Korrektur |
|---|---|---|
| L03637.xml | »plante anläßlich des bevorstehenden 50. Geburtstages« | anlässlich |
| L03638.xml | »Auf dem Poststempel läßt sich entziffern« | lässt |
| L03702.xml | »läßt sich nur zum Teil rekonstruieren« | lässt |
| L03703.xml | »läßt sich nur zum Teil rekonstruieren« | lässt |
| L04318.xml | »abschliessende(n)« (zweimal) | abschließende(n) |

---

## 2. Prüffälle in Herausgeberkommentaren (Verifikation nötig)

- `L01089.xml`, `L01090.xml`: »die einzige vornehmbare zeitliche Einordnung« – ungewöhnliche
  Wortbildung; besser z. B. »die einzige mögliche zeitliche Einordnung«.
- `L03107.xml`: »ist der der Tagebucheintrag zeitlich nach diesem Schreiben anzusetzen« –
  eines der beiden »der« ist zu streichen (grammatisch nicht als Relativpronomen lesbar).
- `L00707.xml`: Im zitierten Zeitungstext öffnet ›Freiwild mit ›, schließt aber mit « –
  Anführungszeichen inkonsistent (›…« statt ›…‹).
- `L01946.xml`: Bibliografie »Bastei-Szene …: »Der junge Medardus« – öffnendes » ohne
  schließendes « im Titel.
- `L03887.xml`: Anführungszeichen im Kommentar unpaarig (»=1, «=2).
- Unpaarige runde Klammern in Kommentaren (möglicherweise fehlt jeweils eine schließende
  Klammer): `L01240.xml`, `L01337.xml`, `L02737.xml`, `L02800.xml`, `L03519.xml`,
  `L03774.xml`. (`L03035.xml` ist ein Fehlalarm: Nummerierung »1.)«.)
- `L03895.xml`: Kommentar »auch: diskurieren: eine Frage lebhaft erörtern« – falls
  »diskutieren« gemeint ist, Tippfehler; falls die Nebenform gemeint ist, ok.

---

## 3. Prüffälle im Brieftext (gegen Faksimile zu prüfen)

### 3a. Wortdopplungen im Brieftext

Möglicherweise echte Dittografien der Schreiber (dann ok), möglicherweise
Transkriptionsversehen. Aussortiert sind bereits Artefakte aus Briefkopf/Adresse
(z. B. »Bureau à Paris« + Datumszeile »Paris, …«; Kuvertadresse »Wien« + Ortszeile »Wien«;
Ortsname »Baden-Baden«) – diese sind unten nicht mehr enthalten, sofern eindeutig.

- `L00130.xml`: »denken Sie ſich nur nur: ich – will – eine – Kritik …«
- `L00138.xml`: »etwas ſagen: wir wir ſollten doch einmal wieder«
- `L00191.xml`: »wäre ich mit mit Anatol zu ſpät gekommen«
- `L00239.xml`: »der publiken und privaten privaten und publiken Sicherheit« (rhetorisches Spiel? wirkt beabsichtigt, dennoch prüfen)
- `L00545.xml`: »im Herbſt wieder ein ein Stück von Ihnen«
- `L00696.xml`: »ſeine ganze Zeit, und und ſo«
- `L00703.xml`: »Es thut mir ſehr ſehr leid« (wohl original, typische Verstärkung)
- `L00765.xml`: »Baron Berger uſw uſw« (wohl original)
- `L01446.xml`, `L01545.xml`: »Wir grüßen Sie Beide Beide.« (zweimal dieselbe Wendung bei demselben Schreiber – könnte original sein)
- `L01722.xml`: »das ich als als hundsjunger Menſch gedacht«
- `L01819.xml`: »würden uns sehr sehr freuen« (wohl original)
- `L01900.xml`: »Geben Sie mir Ihre Hand, Sebastian Sebastian:« (Dramentext; zweites »Sebastian« ist vermutlich Sprecherangabe – Auszeichnung prüfen)
- `L01923.xml`: »Sonntag oder Montag Montag oder Dienstag«
- `L02035.xml`: »in so vielen vielen Jahren« (wohl original)
- `L02119.xml`: »ſende ich Ihnen dies und und nicht das Durchſchlagsexemplar«
- `L02246.xml`: »mit Gründlichkeit und und pſychologiſcher Feinheit«
- `L02297.xml`: »und viele viele Erinnerungen« (wohl original)
- `L02326.xml`: »ganz ganz einſam« (wohl original)
- `L02384.xml`: »wollen wir mehr mehr in alter ergebenheit« (Telegramm Hauptmann – prüfen)
- `L02478.xml`: »Ihre junge Tochter war war Schmuck des Hauses«
- `L02510.xml`: »deren ſie ſie so dringend bedarf« (grammatisch möglich: »deren sie sie … abgewinnen könne«? prüfen)
- `L02513.xml`: »mein lieber lieber Hugo« (wohl original)
- `L02570.xml`, `L02576.xml`: »sehr sehr« (wohl original)
- `L02608.xml`: »bei lieben lieben Menſchen« (wohl original)
- `L02614.xml`: »tritt das Weſentliche klar klar hervor«; »Theile Theile mir mit«; »und zwar zwar recht herzlich« – drei Dopplungen in einer Datei, das spricht für Transkriptionsversehen
- `L02620.xml`: »mit Zwiſchenräumen von von einem Monat«
- `L02621.xml`: »Geiſt Geiſt natürlich auch«
- `L02622.xml`: »vorher Alles Alles eitel Freiheit«; »wie ehrlich ehrlich ich bin«
- `L02661.xml`: »und wer den ertödten ertödten will«
- `L02666.xml`: »ſympathiſch iſt, ohne ohne ſchön zu ſein«
- `L02668.xml`: »mit Händeſchütteln vom Leibe Leibe zu halten«
- `L02670.xml`: »reißt reißt das Leben die Thür auf«
- `L02671.xml`: »weil heut heut wieder einmal die Wien-Wunde offen iſt«
- `L02697.xml`: »geht auch ein Leid Leid aus Deinem Leben«
- `L02729.xml`: »eiſern erzwang, ging ging noch«
- `L02730.xml`: »ein paar Affichen Affichen an Dich ab«
- `L02738.xml`: »Die Doppel Doppel-Adjektive« (bei Zeilenumbruch mit Trennstrich? prüfen)
- `L02739.xml`: »ich möchte gern hinunter hinunter, unter die Erde«
- `L02741.xml`: »Die Ärzte Ärzte ſagen mir nichts«
- `L02742.xml`: »Goldmann oder das Gewitter Gewitter?«
- `L02745.xml`: »um die Anfrage genau genau beantworten zu können«
- `L02748.xml`: »kommt Gutes Gutes, nichts als Gutes«
- `L02750.xml`: »ich ſchaff ſchaff’ Dir ſchon«
- `L02751.xml`: »serrer un jour la main main en ami«
- `L02753.xml`: »Stück zu ſehen ſehen«; »nein, ich weiß weiß!«
- `L02754.xml`: »Ich hätte hätte Dir ſoviel zu ſagen«
- `L02756.xml`: »aus all all’ den Spiegeln«; »hat ſichtlich ſichtlich in der Abſicht«
- `L02758.xml`: »Drum Drum iſts wohl beſſer«; »jede jede nur irgend mögliche Gemeinheit«; »daß Du mir mir langſam entrückt wirſt«
- `L02760.xml`: »die Poſt gewiſſenhaft verklebt verklebt hat«
- `L02766.xml`: »Bahr iſt ſo zu Dir, weil weil er ein Schurke iſt«
- `L02769.xml`: »der Rabbi Blo Bloch Bloch« (Streichung + Dopplung? Auszeichnung prüfen)
- `L02774.xml`: »zahlt ſicher ſicher nichts«
- `L02786.xml`: »einen Brief von Nansen bei bei«
- `L02789.xml`: »denn darin lag lag lag Deine ganze Art« (dreifach!)
- `L02790.xml`: »Wenn Du den Leo Leo Fanjung ſiehſt«
- `L02791.xml`: »Das ſind ſo die wahren wahren inneren Vorgänge«
- `L02792.xml`: »hat mich rieſig rieſig gefreut«; »muß wohl erſt reifen reifen«; »waren ſchon Alle Alle da«; »Fühlhörner ins Leben Leben aus«
- `L02804.xml`: »wird natürlich hier raſch raſch gefunden ſein«
- `L02805.xml`: »zu Ende. Aber Aber ich mache mir«
- `L02806.xml`: »Nenne Nenne mir ein Maximum«; »achten! Nun Nun erfahre ich«
- `L02823.xml`: »bald Ohrenklingen bei bei mir bemerken«
- `L02839.xml`: »ſo halte halte ich das für einen Fehlſchluß«
- `L02841.xml`: »Es hat mich recht recht ſehr amüſirt«
- `L02842.xml`: »herumirren? Ins Ins Weite gehen«
- `L02845.xml`: »iſt ſchön; aber aber es zu ſehen«
- `L02849.xml`: »mit Frau Bahr Bahr zuſammen«
- `L02854.xml`: »recht gern mit ihr abfinden abfinden«; »die alte alten alten Zeiten«; »alle Deine lieben lieben Briefe«; »Dein Paul Paul Goldmann«
- `L02858.xml`: »welch’ ein Schemen alle alle Deine Leiden«
- `L02861.xml`: »zu neun neun Zehnteln«; »Ich meine nicht nicht, daß«; »Ich bat bat Dich ſchon«
- `L02867.xml`: »zur Berichterſtattung über über den Congreß«
- `L02868.xml`: »der Frankfurter Zeitung als als Nachfolger«; »in Berlin ſehr entrückt entrückt geweſen«
- `L02872.xml`: »nimmſt Du ſelbſtverſtändlich mit mit mir ein«
- `L02874.xml`: »zu bitten, daß daß Du mich dort erwarteſt«; »wieder in Wien biſt biſt«
- `L02876.xml`: »an den jetzigen Wiener Wiener Verhältniſſen«
- `L02888.xml`: »der herrliche Dom Dom.«
- `L02899.xml`: »etwas Geniales darin darin«
- `L02905.xml`: »ruhig und natürlich natürlich leben laſſen«
- `L02909.xml`: »des Loslöſens des Lebenden von dem dem Tode Verfallenen« (grammatisch korrekt möglich: »von dem dem Tode Verfallenen« – wohl kein Fehler)
- `L02911.xml`: »ſondern nur nur ein Franzoſe«
- `L02916.xml`: »Der Satz wurde wurde geſtrichen«; »noch recht recht hübſches Mädchen«
- `L02931.xml`: »die Wirkung iſt: alle alle Welt«
- `L02934.xml`: »Burſch ohne Wärme Wärme und Poeſie«
- `L02936.xml`: »Schreib’ mir bald und ſei ſei von Herzen gegrüßt«
- `L02988.xml`: »und immer immer wieder«
- `L03070.xml`: »die Sympathien, die man man für Dich hegt«
- `L03071.xml`: »Wenn nicht nicht, ſo werde ich«
- `L03076.xml`: »bleibt. Ende Ende Auguſt muß ich«
- `L03085.xml`: »Daß Wann kommſt kommſt Du?«; »wenigſtens etwas etwas Ordentliches«
- `L03086.xml`: »haben viel davon verſtanden verſtanden«
- `L03088.xml`: »Worte ohne Sinn Sinn zu gebrauchen«
- `L03149.xml`: »ſo eine eine Leiche, ec. ec.«
- `L03194.xml`: »daß Du mir nie nie mit Abſicht wehgethan haſt«
- `L03195.xml`: »zum Höchſten warſt und weil weil Dich«; »bemerkt; aber aber (wenn …«
- `L03204.xml`: »Aber das Schreiben Schreiben wäre ſehr einfach«
- `L03211.xml`: »daß die junge Dame Dame ſich aufrafft«
- `L03213.xml`: »der das junge Mädchen liebt liebt«
- `L03214.xml`: »geſellſchaftliches Treiben Treiben hineinzugerathen«
- `L03224.xml`: »nicht ſo kurz und ſo eilig eilig«
- `L03367.xml`: »Du biſt aber aber nicht im Mindeſten gebunden«
- `L03374.xml`: »Er iſt in Baden Baden« (könnte Baden-Baden sein – prüfen)
- `L03387.xml`: »für heut Abend eine Loge Loge im Theater an der Wien«
- `L03389.xml`: »wollte es, daß daß ich Bahr«; »hat mich mich immer heftig gereizt«
- `L03401.xml`: »Ihr Felix Salten Salten« (Unterschrift + Kuvert? prüfen)
- `L03415.xml`: »drum wissen, weil weil ich mich schäme«
- `L03440.xml`: »erkrankt, ſie ſie hat längere Zeit«; »Von ganzem Herzen aber aber ſtimme ich«; »und wenn wenn Du mir Deine Hände reichſt«
- `L03445.xml`: »gedenkſt Du Dich damit damit an dem Wettkampf«
- `L03475.xml`: »nur ja nicht verletze verletze verletze« (dreifach; mit Streichung? Auszeichnung prüfen); »Selbſterziehung hin hin«
- `L03527.xml`: »hat, wie gewöhnlich, Blech Blech geſchrieben«
- `L03530.xml`: »Warum haben Sie mir nicht vorher vorher geſchrieben«; »Herzliche Grüße an Sie Beide Beide«
- `L03690.xml`: »Roda Roda« (zweimal – Schriftstellername Roda Roda, korrekt!)
- `L03722.xml`: »über die Schulter blickend – – und und? – – – Und?!« (wohl original/rhetorisch)
- `L03750.xml`: »vielen vielen Dank« (wohl original)
- `L03843.xml`: »es soll soll nur fort aus meinen Sorgen«
- `L03847.xml`: »lieber Schnitzler). Dann Dann ist das Manuscript«
- `L03851.xml`: »haben Sie viel viel Glück« (wohl original)
- `L04018.xml`: »kommen Sie wo möglich nicht nicht ſpät« (Sinn kehrt sich um – prüfen!)
- `L04239.xml`: »und es lockt mich mich zu leben«
- `L04362.xml`: »Charleys Tante an mit mit Heini als Jack«

Auffällig: Die Häufung in `L02614`–`L03445` betrifft überwiegend die Briefe **Paul
Goldmanns** – entweder eine Eigenheit dieses Schreibers (Dittografien im Original)
oder ein systematisches Problem einer Transkriptionskampagne. Stichprobenartige
Faksimile-Prüfung empfohlen.

### 3b. Unpaarige Guillemets im Brieftext

Kann originalgetreu sein (Schreiber vergisst schließendes Zeichen); zu prüfen, ob
Transkriptionsfehler:

`L00112` (»=3/«=4), `L00130` (4/3), `L00162` (2/1), `L00493` (19/17), `L00686` (7/6),
`L01205` (5/1), `L01555` (3/4), `L01563` (2/3), `L01900` (19/18), `L02114` (5/4),
`L02244` (1/0), `L02260` (10/9), `L02319` (7/6), `L02531` (6/5), `L02688` (0/1),
`L02746` (3/2), `L02748` (12/11), `L02944` (2/1), `L03097` (6/7), `L03196` (5/4),
`L03710` (7/6), `L03724` (7/6), `L03739` (0/1), `L03844` (1/2), `L03847` (2/1),
`L03913` (3/2), `L03941` (4/5), `L03967` (3/4), `L04226` (10/11), `L04239` (5/3),
`L04301` (2/1), `L04330` (2/1)

### 3c. Dreifachbuchstaben im Brieftext (gegen Faksimile zu prüfen)

Korrekte Komposita (Schlussszene, Schifffahrt, Massstäbe, Nussschale usw.) sind
aussortiert. Bei Schreibern mit Geminationsstrichen (»kōen« = kommen) können solche
Dopplungen leicht bei der Auflösung entstehen:

- `L00325.xml`: »zuſammmenſtrömen« (auch unter 3a gelistet)
- `L00586.xml`, `L00590.xml`, `L00592.xml`: Adresse »Franzensgassse 54« (dreimal, jeweils Kuvert)
- `L00953.xml`: »es iſt abſolut unſinnnig«
- `L02363.xml`: »die sogenannnte Reigen-Affaire«
- `L02572.xml`: »meine andern Arbeiten kennnen lernen«
- `L02573.xml`, `L02575.xml`: »Bernried/Starnbergerseee«
- `L02649.xml`: »auf einen Sprung herkommmen« (dort auch »ſch ſchreib’ mir«)
- `L02660.xml`: »Weiß der Himmmel«
- `L02742.xml`: »Ich bin innnerlich ganz fertig mit ihm«
- `L02771.xml`: »Schlimme Dinge, ſchlimmme Dinge!« (Emphase? prüfen)
- `L02892.xml`: »iſt die Stimmmung in der Redaktion«
- `L03152.xml`: »da ich vorausssichtlich von hier nicht wegkomme«
- `L03158.xml`: »etwas darüber mitttheilen«
- `L03434.xml`: »nicht zur Sprache kommmen«
- `L03553.xml`: »mit Herrn Benedikt zusammmen«
- `L03558.xml`: »Der graue Himmmel macht mich kaput«
- `L03738.xml`: »das ich natürlich partienweise schon kannnte«
- `L03901.xml`: »etwas hervorrragendes zu leiſten«
- `L04093.xml`: »war ſie vollkommen irrſinnnig«

(Bewusst nicht gelistet: »Phrrryne«/»darrrfſt« in L00376 – erkennbar lautmalerisch.)

---

## 4. Befunde aus der kritischen Lektüre

Fortlaufende Lektüre ab L00001. Notiert wird nur, was beanstandet wird; gelesene
Dateien ohne Befund erscheinen nicht einzeln.

- **L00002** (K1): »Das erste Heft der Modernen Dichtung war am 1. 1. 1891 erschienen.« –
  Der Brief ist vom 31. 1. 1890 und spricht von der bereits erscheinenden Zeitschrift;
  laut Kommentar zu L00003 erschien das Maiheft am 1. 5. 1890. Es muss **1. 1. 1890** heißen.
- **L00041** (K1): »Am 2. 9. 1891 hatte sich zum 20. Mal der Tag von Sedan […] gejährt« –
  Sedan war am 2. 9. **1870**, am 2. 9. 1891 jährte er sich also zum **21.** Mal. Zudem ist
  die Gleichsetzung »Tag von Sedan (Ende des Deutsch-Französischen Krieges von 1870/1871)«
  schief: Die Schlacht von Sedan war kriegsentscheidend, das Kriegsende kam erst 1871.
- **L00058** (K1): »Aufbewahrt zwischen Korrespondenzstücken von Juni und Juli 1893, ist
  doch keine nähere Bestimmung möglich.« – hängender Partizipialanschluss; gemeint wohl:
  »Es ist zwischen Korrespondenzstücken von Juni und Juli 1893 aufbewahrt, doch ist keine
  nähere Bestimmung möglich.«
- **L00065** (K1): »dass am Vortag nicht mehr von »Sonntag« sondern von »morgen« die Rede« –
  fehlendes Komma vor »sondern«.
- **L00078** (K2): »Die Morgenausgabe der Frankfurter Zeitung vom 1. 3. **1893** war …
  beschlagnahmt worden« – der Brief ist vom 10. 3. 1892; gemeint sein muss der 1. 3. **1892**.
- **L00078** (K1): »In: Wiener **Allgemeinen** Zeitung, Nr. 4213« – Kasusfehler, in der
  bibliografischen Angabe muss es »Wiener Allgemeine Zeitung« heißen.
- **L00120** (K1): »Durch die Übersiedlung Beer-Hofmannss« – im XML steht
  `<rs>Beer-Hofmanns</rs>s`, das Genitiv-s ist doppelt (einmal im rs, einmal danach).
- **L00121** (K3): »nach Bougettes (einer herausgebackene Speise …)« – Deklinationsfehler:
  »einer herausgebackene**n** Speise«.
- **L00126** (K1): `<ref type="schnitzler-kultur" subtype="date-only" target="pmb41674"/>` –
  das Target eines date-only-Refs ist eine PMB-ID statt eines Datums (»Schnitzler war am
  Sonntag, dem 〈?〉 in Gefallene Engel«); Rendering prüfen, vermutlich fehlt das Datum.
  Außerdem im selben Kommentar: »Obzwar der Poststempel … eindeutig ›93‹ zeigt, scheint
  dies doch durch den Inhalt ausgeschlossen« – Konstruktion »Obzwar … scheint dies doch«
  ist doppelt konzessiv; eines von beiden streichen.

- **L00169** (K1): »ein Besuch Schnitzlers im Carl-Theaters« – überschüssiges Genitiv-s
  (im XML endet der rs-Inhalt auf »Carl-Theaters«); richtig: »im Carl-Theater«.
- **L00170** (K3): »was, gemeinsam mit den Datierungen der vorangehenden zwei
  Korrespondenzstücke, auf die hier geantwortet wird, nach vorne hin beschränkt.« – Satz
  ohne Objekt; gemeint wohl »… die Datierung nach vorne hin beschränkt«.
- **L00204** (Brieftext): »was für Sonntag morgen Nachmittag projektirt **ift**« –
  Transkriptionsfehler f statt ſ, richtig »iſt«.
- **L00268** (K1): »Ein solches kann für diesen Tag nicht nachgewiesen werden, sehr wohl
  aber **den ersten** von sechs Abenden« – Kasusfehler, im Passiv muss es »der erste« heißen.
- **L00291** (K1): Der Tagebuch-Ref zum Theaterbesuch (Mounet-Sully als Hamlet) zeigt auf
  `target="1893-01-21"` – die Aufführung war aber am 21. 1. **1894** (Brief vom 15. 1. 1894).
- **L00276** (Brieftext, Prüffall): »der Begründer der sog. **naturhyſteriſchen** Schule« –
  Schönlein begründete die »naturhistorische Schule«; entweder Bahrs (beabsichtigtes?)
  Wortspiel oder Transkriptionsfehler – gegen Faksimile prüfen.

- **L00325** (Brieftext, Prüffall): »die zuſammmenſtrömen mußte« – dreifaches m
  (»zusammmen«); gegen Faksimile prüfen, vermutlich Transkriptionsfehler.
- **L00366** (K1): »Zwei Tage zuvor **hatten er** Beer-Hofmann zuletzt gesehen« – Kongruenzfehler,
  richtig »hatte er«. Außerdem am Ende: »frühestens am 5. und spätestens am 6. 9. **1895**
  verfasst« – muss **1894** heißen (gesamter Kontext September 1894).

- **L00534** (K1): »während bei zweiterem bereits am Vortag ein Essen mit Brahm bei
  Beer-Hofmann stattgefunden, sodass die Kommunikation eher zu knapp ausfällt« – fehlendes
  Hilfsverb: »stattgefunden **hatte**«. (»zweiterem« ist zudem umgangssprachlich.)
- **L00534** (Brieftext, Prüffall): »nachmahlen Sie Freitag Abend bei uns« – vermutlich
  »nach**t**mahlen« (vgl. L00549: »wo nachtmahl ich heute«); gegen Faksimile prüfen.

- **L00857** (Datierung, Prüffall): Titel und correspAction datieren auf den **16. 11. 1898**,
  die Datumszeile des Briefs lautet aber »Dienstag, 15/11 98« – und der 15. 11. 1898 *war*
  ein Dienstag, die Schreiberdatierung ist also in sich stimmig. Falls die Editionsdatierung
  (z. B. nach Poststempel) beabsichtigt ist, fehlt eine erläuternde Anmerkung.

- **L00888** (K1, Prüffall): Zitierter Titel von Bahrs Artikel »Premièren. (Zur Première
  des Lustspiels ›Unser Käthchen‹ … am 4. Februar **1898**)« – die Premiere war am
  4. 2. **1899** (so auch K1 zu L00885). Prüfen, ob der Druckfehler schon in der
  »Zeit« steht (dann ggf. [sic]) oder bei der Transkription entstand.
- **L00896** (K1): `<ref target="1900-03-01" …/>` – die Uraufführung der drei Einakter
  (Der grüne Kakadu, Paracelsus, Die Gefährtin) war am 1. 3. **1899**, nicht 1900; der
  Tagebuch-Link zeigt aufs falsche Jahr.

- **L01138** (Brieftext, Prüffall): Datumszeile »St Anton 1. 7. **109**.« – im XML
  `<date when="1901-07-01">1. 7. 109</date>`; vermutlich Transkriptionsfehler für
  »1. 7. 901« (sonst Schreiberversehen, dann Anmerkung erwägen).

- **L01399** (K1): »In Goethe**ss** Italienischer Reise steht …« – doppeltes Genitiv-s
  (im XML `<rs>Goethes</rs>s`, gleicher Fehlertyp wie L00120).

- **Systematischer Befund: doppeltes Genitiv-s an rs-Grenzen** (`…s</rs>s` – das
  Genitiv-s steht sowohl im rs-Element als auch dahinter; gerendert erscheint »ss«).
  Vollständige Trefferliste aus dem Scan aller 4366 Dateien:
  - `L00120.xml` (Kommentar): »Beer-Hofmannss« *(bereits oben notiert)*
  - `L01399.xml` (Kommentar): »Goethess Italienischer Reise« *(bereits oben notiert)*
  - `L01710.xml` (Brieftext, dreimal): »Alfredss Lob«, »Alfredss Tadel«, »Alfredss Lotterbank«
  - `L01749.xml` (Kommentar): »Verwandte Hofmannsthalss mütterlicherseits«
  - `L02710.xml`: »E. Piersonss Verlag«
  - `L02725.xml`: »Dürerss Briefe, Tagebücher und Reime«
  - `L02911.xml` (Brieftext): »Goethess Geſpräche«
  - `L02934.xml` (Brieftext): »Hermann Bahrss Luſtſpiel«
  - `L03093.xml` (Brieftext, zweimal): »Hauptmannss Niedergang«

- **L01480** (K1): `<ref target="1890-12-21" …/>` – der Brief ist vom 16. 12. 1904 und
  »Mittwoch« meint den 21. 12. **1904** (Geburtstag von Hofmannsthals Vater, vgl. L01479);
  der Tagebuch-Link zeigt aufs Jahr 1890.

- **L03080** (K2): `<ref type="schnitzler-tagebuch" target="1900-08-21" source="see"/>` –
  einziger Beleg von `source=` statt `subtype=` im gesamten Korpus; vermutlich
  `subtype="See"` gemeint (der Link verliert sonst wohl seine Darstellungsform).

- **L01497** (Anm.): Die textConst-Anmerkung lautet wörtlich »handschriftlich gestrichen
  oder unterstrichen?« – eine offen gebliebene redaktionelle Frage (Fragezeichen!), die so
  in der Publikation steht. Gegen das Faksimile entscheiden und umformulieren.
- **L01510**: »die Haupſache« (statt »Hauptſache«) – Prüffall Faksimile: fehlendes t
  bei Schnitzler oder Transkriptionsfehler?
- **L01527** (Adresse): »Wien VIII Spöttelgasse 7« – die Spöttelgasse liegt im XVIII. Bezirk
  (so in allen anderen Briefen). Prüffall Faksimile: Verschreiber Beer-Hofmanns (dann ggf.
  Anmerkung erwägen) oder Transkriptionsfehler (X vergessen)?

- **L01534**: »Ich bediene mich Wörter eines Vergleichs« – grammatisch unmöglich
  (»sich bedienen« + Genitiv »eines Vergleichs«; »Wörter« passt nicht). Prüffall
  Faksimile: vermutlich Verlesung von »wieder« (»Ich bediene mich wieder eines Vergleichs«).
- **L01547**: »eine Ahnung von dem Wunsch erfüllſt« – »erfüllſt« statt »erfüllt«.
  Prüffall Faksimile: Verschreiber Schnitzlers oder Transkriptionsfehler?
- **L01550** (Adresse): »Wien XIX / Spöttelgaſſe 7« – die Spöttelgasse liegt im
  XVIII. Bezirk. Prüffall Faksimile (analog L01527: dort »VIII«).
- **L01563**: Zur bereits notierten Guillemet-Unwucht die genaue Stelle: »für Ihr
  »Zwischenspiel« habe«.« – das schließende »«« nach »habe« ist überzählig
  (oder Verschreiber Seligmanns, dann Prüffall Faksimile).

- **L01566** (Titelblatt-Transkript): »von Max Burckhart.« – Prüffall Faksimile:
  steht auf dem gedruckten Titelblatt wirklich »Burckhart« (statt Burckhard)?
- **L01597** (Gedicht): »mit klaaren / Augen« – Prüffall Faksimile: schrieb
  Beer-Hofmann tatsächlich »klaaren« oder Transkriptionsdoppelung?
- **L01598** (Datierung): Widerspruch – correspAction datiert »[vor dem 21. 5.? 1906]«
  (`when="1906-05-20"`), der Kommentar K1 verweist aber auf das Tagebuch vom
  **21. 6. 1906** und sagt, der Brief sei »kurz zuvor geschickt worden«. Entweder
  Datierung auf [vor dem 21. 6.? 1906] ändern oder der Ref/Kommentar ist falsch.

- **L01602** (Adresse): »XVII Spöttelgasse 7« – falscher Bezirk (XVIII). Kommt aber
  in neun Briefen vor (L01602, L01646, L01653, L01659, L01667, L01684, L01685, L01729,
  L01733, offenbar alle Hofmannsthal), also wohl dessen konsequente (falsche) Schreibgewohnheit
  und authentisch – ein Stichproben-Faksimilecheck genügt. Anders die Einzelfälle
  L01527 (»VIII«) und L01550 (»XIX«).
- **L01604** (K2): »par dépit – französisch: aus Neid« – Übersetzungsfehler: »dépit«
  heißt Verdruss/Trotz/gekränkter Stolz (»aus Trotz«), nicht Neid (das wäre »envie«).
- **L01615** (Adresse): »Marienlyst / ver / Helsingør« – »ver« ist wohl Verlesung des
  dänischen »ved« (bei). Prüffall Faksimile.
- **L01620, L01621** (Kartenaufdruck): »Krenborg Slot« – der gedruckte Kartentitel
  dürfte »Kronborg Slot« lauten (so auch der Kommentar K1 in L01620: »Schloss
  Kronborg«). Prüffall Faksimile, gleicher Fehler auf beiden Karten.

- **L01672** (Schluss): »Herzlichchst Ihr Hugo« – doppeltes »ch«. Prüffall Faksimile:
  Verschreiber Hofmannsthals oder Transkriptionsfehler?
- **L01700**: »bis 26. (27.. 28)?« – nach »27.« folgt ein zweiter Punkt außerhalb des
  date-Elements (`<date>27.</date>.`). Prüffall: überzähliger Punkt in der Transkription
  oder so im Original?

- **L01724** (Bildbeschreibung): »Zeichung von Altenberg mit Sprechblase« – in der
  redaktionellen `<supplied type="image-description">` fehlt das n: »Zeich**n**ung«
  (verifizierter Tippfehler im Herausgebertext).
- **L01727** (K1): Zitatende »…ein Kompliment über sein jüngstes Buch.«.« – Punkt
  innerhalb und außerhalb der Guillemets, einer ist überzählig.

- **L01791** (K1): Übersetzung »liest immer mit verklärter Mine« – richtig ist
  »Mie­ne« (frz. »mine«); »Mine« wäre Sprengkörper/Bleistiftmine. Verifizierter
  Fehler im Herausgeberkommentar.
- **L01796** (Beilage C. Müller): »die Rolle der der ›Mizi Schlager‹ vorſpreche« –
  Doppelung »der der« (von der Dopplungs-Rasterliste nicht erfasst); dazu
  »nageliegendſten« (naheliegendsten). Prüffälle Faksimile: Verschreiber Müllers
  oder Transkriptionsfehler?

- **L01813**: »möchte ich die morg. Einladg verreinen« – »verreinen« gibt es nicht;
  Prüffall Faksimile: wohl Verlesung von »verneinen« (rn→rr).
- **L01828** (Adresse): »Wien XIV / Ottakringerstr. 114« – die Ottakringerstraße liegt
  im XVI. Bezirk (so alle Ehrenstein-Briefe); zudem im Text »Zu mündlicher Erkärung«
  statt »Erklärung«. Beides Prüffälle Faksimile (Verschreiber Schnitzlers auf der
  Karte oder Transkriptionsfehler).

- **L01837** (K1): `<ref target="1909-10-16"/>` zu »In 14 Tagen ſpielt die Després
  hier die Elektra« – der Brief ist vom 1. 4. 1909, das Gastspiel war Mitte April
  (K2 zitiert die NFP vom 17. 4. 1909). Der Tagebuch-Link muss **1909-04-16**
  heißen, nicht Oktober. Verifizierter Datumsfehler.
- **L01856** (Adresse): »Wien XVIIII Spöttelgaſse 7« – vier I. Prüffall Faksimile:
  Burckhards Schreibweise oder überzähliges I der Transkription?
- **L01857**: »in Anſspruch nahm« – ſ+s doppelt. Prüffall Faksimile.

- **L01877** (Unterschrift): Der Brief Hofmannsthals an Schnitzler schließt mit
  `<signed>Arthur</signed>` (»Ihr Arthur«). Prüffall Faksimile: Entweder bewusster
  Scherz Hofmannsthals (der Brief spielt mit Identitäten: »der Sala bin ja ich!«) –
  dann wäre eine erläuternde Anmerkung hilfreich – oder Transkriptionsfehler für »Hugo«.

- **L01912** (K2): »den von ihr behaupteten Suizid zu wiederlegen« – richtig:
  »widerlegen«. Verifizierter Tippfehler im Herausgeberkommentar.
- **L01931** (K1): Die Anmerkung enthält `<ref target="L01931"/>` – einen Verweis
  des Briefs auf sich selbst (»scheint das Schreiben vom [→L01931] auf diesen Brief
  die Antwort zu geben«). Gemeint ist wohl das Gegenstück (L01932?). Verifizierter
  Verweisfehler.
- **L01937**: »dieſes vornehmen ſcharfgeſchliffenen Kuntwerks« – »Kuntwerks« statt
  »Kunſtwerks« (kurz darauf richtig »Als Kunſtwerk«). Prüffall Faksimile:
  Verschreiber Wedekinds oder Transkriptionsfehler?

- **L01957** (Adresse): »Wien XIX Sternwartestrasse 71« – die Sternwartestraße liegt
  im XVIII. Bezirk. Prüffall Faksimile (wohl Verschreiber der Kartenschreiber;
  reiht sich in die Bezirks-Serie L01527/L01550/L01828 ein).
- **L01961** (K2): »hatte die Premiere … gemeinsam mit Liebelei am im Burgtheater
  stattgefunden« – »am im«: eine Präposition ist überzählig (Rest einer Umformulierung).
  Verifizierter Fehler im Herausgeberkommentar.

- **L01981** (K5): Zu »Ich selbst fahre etwa am 7. Dezember nach München (Vorlesung)«
  lautet K5 »am 9. 12. 1909« – der Brief ist vom 17. 11. 1910, gemeint ist der
  9. 12. **1910**. Verifizierter Jahresfehler.
- **L01985** (Adresse): »Wien XIII Spöttelgasse 7« – falscher Bezirk (XVIII) und
  zugleich die veraltete Adresse (Schnitzler wohnte seit Juli 1910 Sternwartestraße).
  Prüffall Faksimile (Bezirks-Serie).
- **L01994** (Adresse): »Wien XIV Ottakringer Hptstr 114« – wie L01828 wieder XIV
  statt XVI. Prüffall Faksimile.
- **L01998** (K2): Datierungswiderspruch – K2 stützt die Datierung auf Blei an Lukács
  vom »26. 12. 1909« und Lukács vom »6. 1. 1910«, aber der Brief ist auf
  [Anfang? Januar **1911**] datiert und K1 sagt, der Aufsatz sei »unmittelbar nach dem
  Brief« (Februar 1911) erschienen. Vermutlich müssen die zitierten Briefdaten
  26. 12. 1910 / 6. 1. 1911 heißen (Schnitzlers Münchner Treffen mit Blei war im
  Dezember 1910); sonst wäre die Datierung des Briefs falsch.
- **L02005** (Datierung): Die Datumszeile des Briefs lautet »Wien, 11. Februar 1911«,
  die correspAction datiert aber »[7.] 2. 1911« (`when="1911-02-07"`) – ohne jede
  erläuternde Anmerkung (Antwortbrief L02006 ist auf [8. 2.] datiert). Entweder
  Anmerkung ergänzen (Verlesung/Schreibirrtum?) oder Datierung prüfen.

- **L02033** (K1): »von Théodor Barrière« – der Dramatiker heißt Théodor**e** Barrière.
- **L02038/L02039** (K1): Widerspruch bei den Simultanpremieren von »Das weite Land«
  am 14. 10. 1911 – L02038-K1 (wie auch L03541): »in neun Städten«, L02039-K1:
  »Eine der sieben gleichzeitigen Theaterpremieren«. Eine Zahl ist falsch.
- **L02039** (K1): »fand am Residenztheater München in München statt« – »München«
  doppelt (im Theaternamen und als Ortsangabe); eines streichen.
- **L02030** (K1): »Schnitzlers Mutter Luise« – sonst stets »Louise« (L02026, L02028);
  Schreibweise vereinheitlichen.

- **L02045** (Adresse): »Hasenauerstr 46« statt 59 (Beer-Hofmanns Haus). Prüffall
  Faksimile: Verschreiber Schnitzlers oder Transkriptionsfehler (59→46)?
- **L02047** (Adresse): »Veilissengasse« statt »Veitlissengasse« (fehlendes t).
  Prüffall Faksimile.
- **L02052** (K1): Die zitierte Uraufführungskritik der Arbeiter-Zeitung ist auf
  »15. 11. 1910« datiert – die Uraufführung von »Das weite Land« war aber am
  14. 10. 1911; richtig wohl **15. 10. 1911** (Jg. 23 der AZ = 1911). Verifizierter
  Datumsfehler im Kommentar.
- **L02065**: »weiter fortzuſsetzen vermag« – ſ+s doppelt (fortzuſetzen). Prüffall
  Faksimile (Verschreiber Mells oder Transkription).

- **L02100** (K1): Brandes zitiert in der Widmung »(Ilias IV 235)« – die
  Glaukos-Diomedes-Episode steht aber im **VI.** Gesang (V. 232–236). Der Kommentar
  erläutert die Episode, ohne Brandes' falsche Gesangszahl richtigzustellen –
  Ergänzung empfohlen (»recte: VI 232–236«).

- **L02154**: »wird uns ein besonders Vernügen sein« – »Vernügen« ohne g
  (Vergnügen), dazu »besonders« statt »besonderes«. Prüffall: Tippfehler in
  Schnitzlers Typoskript (dann ggf. Anmerkung) oder Transkriptionsfehler?
- **L02173** (Adresse): »Sternwartestrasse 76« statt 71. Prüffall Faksimile
  (Verschreiber Beer-Hofmanns oder Verlesung).

- **L02195**: »mit unverrichteteter Sache« – Silbendoppelung (»unverrichteter«).
  Prüffall Faksimile: Verschreiber Brandes' oder Transkriptionsfehler?
- **L02210** (Schluss): »herzlichlich grüßend« – Silbendoppelung (»herzlich«/
  »herzlichst«). Prüffall Faksimile: Verschreiber Schnitzlers oder Transkription?

- **L02213**: »und jede einzelne wirkte am Ende, in irgend ein andres Stück gestellt,
  lebendig wirken« – »wirkte … wirken« ergibt keinen Satz; Prüffall Faksimile:
  vermutlich Verlesung von »würde« (»würde … lebendig wirken«).
- **L02216** (Schluss): »sehe ich … mit Vergnügen entgegegen« – Silbendoppelung
  (»entgegen«). Prüffall Faksimile.

- **L02260** (K1): Zu »ἓν διὰ δυοῖν«: Erstens »eins **mit** zwei« – διά heißt
  »durch« (Hendiadyoin = »eins durch zwei«); zweitens »aus zwei Wörten« statt
  »Wörtern«. Zwei verifizierte Fehler in einer Anmerkung.
- **L02262** (Adresse): »Hasenauerstr 54« statt 59. Prüffall Faksimile
  (Verschreiber Schnitzlers oder Verlesung; vgl. L02045 mit »46«).

- **L02288**: Zwei Auffälligkeiten in einer kurzen Karte: »am Mitwwoch (19.)«
  (ww statt ttw) und »Jedenfalls ſreue ich mich« (ſreue statt freue). Prüffall
  Faksimile: Schnitzlers Flüchtigkeit oder Transkriptionsfehler?
- **L02292** (Briefkopf): »Wien XVII. Sternwartestr. 71« – XVII statt XVIII in
  Schnitzlers eigener Datumszeile. Prüffall Faksimile.

- **L02317** (K2): »Casanovas Heimkehr erschien im Dezember 1918« – der Titel der
  Novelle lautet »Casanovas Heim**fahrt**« (so korrekt in L02297-K1 u. ö.).
  Verifizierter Titelfehler im Herausgeberkommentar.

- **L02376** (K1): Zum Gollomb-Interview (New York Evening Post, 5. 6. 1920) steht
  ein Tagebuch-Ref `target="1902-07-02"` – 1902 kann nicht stimmen; gemeint ist wohl
  der **2. 7. 1920** (Ziffferndreher 02/20). Verifizierter Datumsfehler.
- **L02377**: »was Sie und Ihre Kunft mir bedeuten« – »Kunft« statt »Kunſt«;
  klassische ſ/f-Verlesung (vgl. L00204 »ift«). Prüffall Druckvorlage, praktisch
  sicher Transkriptionsfehler.

- **L02402** (Adresse): »Herrchenbadstrasse 26« – die Straße in Baden-Baden heißt
  He**r**chenbadstraße (ein r). Prüffall Faksimile (Verschreiber Beer-Hofmanns
  oder Transkription).

- **L02433** (K1): »Anschließend fuhr Brandes nach Wien, um dort am 8. 4. 1931 den
  Vortrag zu wiederholen« – Brandes starb 1927; richtig ist der 8. 4. **1925**
  (Kontext: Berliner Vortrag 31. 3. 1925; vgl. L02440-K1). Verifizierter Jahresfehler.

- **L02475** (K1): NFP-Zitat der »Bemerkungen« mit »23. 5. 1923« – der Brief (25. 5.
  1926) spricht von der soeben erschienenen Pfingstnummer; Pfingstsonntag 1926 war
  der 23. 5. **1926** (NFP Nr. 22.158 passt zu 1926). Verifizierter Jahresfehler.

- **L02523** (Datumszeile): Transkribiert ist »Wien, 18. 11. 924« – der Brief
  (Nobelpreis-Gratulation an Thomas Mann) stammt aber vom 18. 11. **1929**. Entweder
  Verschreiber Schnitzlers (dann Anmerkung ergänzen) oder Transkriptionsfehler
  (924 statt 929). Ohne Anmerkung widersprechen sich Titel und Text.
- **L02525** (Datumszeile): »Wien d 23/IX 29« – datiert ist der Brief auf den
  23. **11.** 1929 (`when="1929-11-23"`), ohne Anmerkung. IX/XI prüfen; falls Gerty
  sich verschrieb, Anmerkung ergänzen.
- **L02549** (K2): »tant mieux: so viel besser« – idiomatisch »umso besser«.

- **Systematisch: ſ statt f** (Verlesungen von Kurrent-f als Lang-s, gehäuft in der
  Goldmann-Korrespondenz; im Deutschen unmögliche Lautfolgen, daher praktisch sicher
  Transkriptionsfehler – Prüffälle Faksimile):
  - L02608 »ſranzöſiſch« (→ franzöſiſch)
  - L02612 »ſreundſchaftlichen«, »ſür beſtimmte Termine«, »Bücher-Reſerats« (→ Referats)
  - L02614 »das übrige ſällt ab« (→ fällt)
  - L02622 »einen ſreien Augenblick« (→ freien)
  - L02643 »Dank ſür Ihre …« (→ für)
  - L02645 »ſür mich hat ſo ein Wiſch« (→ für)
  - L02646 »nicht recht ſreundſchaftlich« (→ freundſchaftlich)
  - L02649 »mußt ſroh ſein« (→ froh); »als ſrommer Bibelleſer« (→ frommer)
  - L02651 »müßte es Dir ſallen« (→ fallen)
  - L02660 »ſand aber nur« (→ fand)
  - L02664 »ſremd, fremd und fremd« (→ fremd; im selben Satz zweimal richtig!)
  - L02717 »Mir ſällt ein« (→ fällt)
  - L02750 »der ſreilich wenig Verbindungen« (→ freilich)
  - L02757 »Die Überſetzung der ›Liebelei‹ ſinde ich vorzüglich« (→ finde)
  - L02772 »zum dritten Mal angeſangen« (→ angefangen)
  - L02787 »mit dem ich mich rieſig geſreut habe« (→ gefreut)
  - L02806 »unter ſalſchen Namen abgeſtiegen« (→ falschen)
  - L02818 »ſolange es geht und ſahre dann über Muenchen« (→ fahre)
  - L02830 »Heimweh … nach Freundſchaſt, nach Heimlichkeit« (→ Freundſchaft;
    hier ſ statt f an der ft-Position)
  - L02847 »Es ſind noch andere Projecte in der Luſt« (→ Luft)
  Umgekehrte Richtung (f statt ſ): L02804 »Mittag vielleicht zu Haufe« (→ zu
  Hauſe); ebenso L02845 »ich wäre ſchon wieder zu Haufe« und L02904 »Die Verſe
  namentlich find von einer goldenen Reife« (→ ſind).
  - L02900 »Freundſchaft ſür« (→ für)
  (Bereits einzeln notiert: L00204 »ift«, L02288 »ſreue«, L02377 »Kunft«.)
- **Systematisch: ft statt ſt** (»Kunft« = Kunſt): neben L02377 auch **L02661**
  (»Anforderungen an die Kunft jedes Einzelnen«), **L02947** (»den auszuführen
  die Kunft gemangelt hat«) und **L02792** (»zu deſſen Fertigftellung ich drei
  Tage gebraucht« → Fertigſtellung) und **L02894** (»wenn Du nicht zu viel zu
  thun haft« → haſt). Prüffälle Faksimile, praktisch sicher Verlesungen.

- **L02755** (K3, bibl »Journal des débats … Nr. 43, 13. 2. 1895«): Das Jahr ist
  falsch. Die Notiz belegt die Anzeige der *Liebelei*-Buchausgabe, die laut K2 erst
  in den Folgetagen nach der Berliner Premiere (4. 2. **1896**) erschien; auch
  Jg. 108 des Journal des débats entspricht 1896. → 13. 2. 1896. **Verifizierter
  Fehler** (auch im `<bibl>`-Element).
- **L02757**: »Schreib’, bittae, an Frau Aubry« – »bittae« steht so im XML, ohne
  textConst-Anmerkung. Entweder Transkriptionsfehler oder diplomatisch getreuer
  Schreibfehler Goldmanns; dann Anmerkung ergänzen. Prüffall Faksimile.
- **L02768** (K1): »möglicherweise die ›Depesche‹ des letzten Briefs,
  `target="L02768"`« – der Verweis zeigt auf den Brief selbst (Selbstverweis wie
  L01931). Gemeint ist der vorangehende Brief (der Kontext um die Duell-Depesche,
  wohl L02791/L02689-Umfeld bzw. der unmittelbar vorausgehende Goldmann-Brief).
  **Verifizierter Fehler.**
- **L02773** (K1): »Nachdem der vorige Brief bereits am `<ref target="L02773"
  subtype="date-only"/>` verfasst worden ist« – Selbstverweis: Der Verweis zeigt
  auf L02773 selbst und rendert dessen eigenes Datum (4. 5. 1896). Gemeint ist
  der vorige Brief **L02772** (29. 4. 1896). **Verifizierter Fehler.**
- **L02774**: »die Du ſchreiben könnteſt und ſchreiben **wiſt**« – wohl »wirſt«
  (oder »willſt«); steht so ohne Anmerkung im XML. Prüffall Faksimile, ggf.
  textConst-Anmerkung ergänzen.
- **L02778**: »Am Tage, wo er dieſe **Correnſpondenz**-Karte verfaßt« – im selben
  Brief zuvor korrekt »Correſpondenz-Karte«. Wohl Transkriptionsfehler (rn statt r).
  Prüffall Faksimile.
- **L02781**: »raſch noch in der letzten **Viertelſunde**« – wohl »Viertelſtunde«
  (t fehlt), ohne Anmerkung. Prüffall Faksimile.
- **L02787/L02790/L02792**: L02787 und L02790 haben »Leo **Fanjung**« (in
  `<hi rend="latintype">`), L02792 dagegen »Leo **Vanjung**«, alle auf pmb26392
  (Leo Van-Jung) verlinkt. Zweimal »Fanjung« spricht eher für eine authentische
  Schreibgewohnheit Goldmanns; die abweichende Stelle in L02792 (oder umgekehrt
  die F-Lesungen) gegen das Faksimile prüfen. Prüffall.
- **L02797** (K1): »Paul Schlenther war 1886 als Nachfolger von Theodor Fontane
  zur Vossischen Zeitung gekommen« – sachlich zu prüfen: Schlenther kam 1886 zur
  Vossischen Zeitung, Fontanes Nachfolger als Theaterkritiker (Königliches
  Schauspielhaus) wurde er aber erst 1889/90; Fontane rezensierte bis 1889. Beide
  Angaben passen nicht zusammen. Prüffall (Formulierung bzw. Jahr korrigieren).

- **L02802** (K4): Der Übersetzung »An Frau J. Marni, respektvolle Anerkennung«
  fehlt das sonst übliche Präfix »französisch:« (vgl. K5/K6 im selben Brief).
  Formale Inkonsequenz.
- **L02806** (K3): »Das Ohrenklingen aufgrund **ders** Otosklerose war gerade
  wieder akut« – Tippfehler, → »der Otosklerose«. **Verifizierter Fehler.**
- **L02809** (K6): »Paris: **Librarie** Hachette 1897« → »Librairie« (einzige
  Stelle im Korpus mit dieser Schreibung, auch im org-Element pmb141468).
  **Verifizierter Fehler.**

- **L02836**: »ein Boden, auf welchem **Sumpfplanzen** wie Bahr gedeihen« – wohl
  »Sumpfpflanzen« (f fehlt), ohne Anmerkung; könnte auch Goldmanns Schreibfehler
  sein. Prüffall Faksimile.
- **L02842**: »Die Geographie, mein theurer Freund, **iſ** niemals Deine ſtarke
  Seite geweſen« – wohl »iſt« (t fehlt), ohne Anmerkung. Prüffall Faksimile.
- **L02824**: »daß alle die harte Mühe nicht **vowärts** hilft« – wohl
  »vorwärts« (r fehlt), ohne Anmerkung. Prüffall Faksimile.
- **L02848**: »Tief **ergeifend** iſt auch der ›Abſchied‹« – wohl »ergreifend«
  (r fehlt), ohne Anmerkung. Prüffall Faksimile.
- **L02861**: »wieviel Trennendes ſich … zwiſchen uns plötzlich **aufrichtig**
  würde« – syntaktisch verlangt der Satz »aufrichten« (sich aufrichten würde);
  wohl Verlesung der Endung, ohne Anmerkung. Prüffall Faksimile.
- **L02869**: »hatte ſeinen Grund in der **Angewißheit** der ganzen Situation« –
  der Kontext (quälende Wartezeit auf Antwort der NFP) verlangt »Ungewißheit«;
  ohne Anmerkung. Prüffall Faksimile (A/U-Verlesung in Kurrent gut möglich).
- **L02871**: »wieder auszufüllen und **langſsam** zu verdecken« – »langſsam«
  mit ſ + s; wohl Transkriptionsversehen für »langſam«. Prüffall Faksimile.
- **L02818** (K3): »Wie wichtig es Goldmann **warm** nicht mit Bahr
  zusammenzutreffen« – Tippfehler, → »war, nicht mit Bahr zusammenzutreffen«
  (Komma fehlt ebenfalls). **Verifizierter Fehler.**
- **L02878** (K1): »Am 21. 6. 1899 reiste Schnitzler nach Belišće, blieb 2 Tage,
  fuhr dann weiter nach Orahovica, wo er ebenfalls für zwei Tage blieb. Über
  Budapest reiste er **am 21. 6. 1899** retour« – Abreise- und Rückreisedatum
  identisch (beide refs `target="1899-06-21"`), obwohl dazwischen mindestens
  vier Tage liegen. Das zweite Datum muss ca. 26./27. 6. 1899 lauten (im
  Tagebuch prüfen). **Verifizierter Fehler** (innerer Widerspruch).

- **L02900** (K7): »Paul Rosengart, Goldmanns Neffe, **Tochter** seiner
  Schwester Vally und deren Mann Josef« – Widerspruch Neffe/Tochter; richtig
  wohl »Sohn seiner Schwester«. **Verifizierter Fehler.**
- **L02910** (K3): »Agnes Sorma gastierte am **4. 6. 1900** und am 12. 4. 1900«
  – Tag und Monat vertauscht: das `date`-Element hat `when="1900-04-06"`, der
  angezeigte Text müsste also »6. 4. 1900« lauten (der Brief vom 13. 4. 1900
  spricht von zwei bereits vergangenen Abenden). **Verifizierter Fehler.**
- **L02934** (K9): »Siehe zum Begriff ›süßes Mädel‹ auch `target="L02934"`« –
  Selbstverweis: Der Verweis zeigt auf den Brief selbst (wie L01931, L02768,
  L02773). Gemeint ist wohl ein anderer Brief oder ein Registereintrag.
  **Verifizierter Fehler.**
- **L02937** (K1): Die Anmerkung zur »Aufführung« besteht nur aus dem Verweis
  `<ref target="L02937" subtype="See"/>` – wieder ein Selbstverweis (wie L01931,
  L02768, L02773, L02934); gemeint ist wohl L02938 (Verschiebung der Premiere).
  **Verifizierter Fehler.**
- **L02988**: »mit anderfarbigen **Crataven** gezeigt haben« – wohl »Cravaten«
  (Buchstabendreher; dreimal zuvor im selben Brief korrekt »Cravate«). Auch
  »anderfarbigen« (statt »andersfarbigen«) prüfen. Prüffall Faksimile.
- **L03011**: »das Ding nicht in **Forsetzungen** zu lesen« – wohl
  »Fortsetzungen« (t fehlt); handschriftlicher Brief Schnitzlers, ohne
  Anmerkung. Prüffall Faksimile (Flüchtigkeit Schnitzlers möglich).
- **L03018** (K1): »die **Erwähung** von Elisabeth Steinrücks
  Rippenfellentzündung« – Tippfehler, → »Erwähnung«. **Verifizierter Fehler.**
- **L03046** (Widmungsexemplar, Titelseite): »Herr Wenzel auf Rehberg **uns**
  ſein Knecht Kaſpar Dinckel« – der gedruckte Buchtitel lautet »… **und** ſein
  Knecht …«; Transkriptionsfehler im `pre-print`-Text. **Verifizierter Fehler**
  (gegen das Faksimile absichern, aber ein Druckfehler auf der Titelseite des
  Buchs ist auszuschließen).
- **L03050** (Widmungsexemplar, Titelseite): »Mit **Zeichungen** von Leo
  Kober« – wohl »Zeichnungen« (n fehlt); im `pre-print`-Text. Wie bei L01724
  (»Zeichung«) gegen das Faksimile prüfen – falls die Buchtitelei tatsächlich
  so druckt, wäre eine Anmerkung sinnvoll. Prüffall.
- **L03055** (K2): »So **gelang** etwa Vacanos Vierakter ›Der Tag‹ am
  19. 1. 1901 … zur Uraufführung« – grammatisch falsch, → »gelangte«.
  **Verifizierter Fehler.**
- **L03116** (K1): »anlässlich des 400. **Jubiläum** der ›Entdeckung‹
  Amerikas« – Genitiv fehlt, → »Jubiläums«. **Verifizierter Fehler.**
- **L03640 (Brieftext)**: Schlussformel »In Verehrung **getreut** Ihr« –
  »getreut« ist kein Wort, gemeint wohl »getreu«. Keine textConst-Anmerkung.
  Transkriptionsfehler oder Zweigs Schreibversehen – Prüffall Faksimile.
- **L03640, K3 (Kommentar)**: »Das Glückwunschtelegramm **Gehart** Hauptmanns«
  – richtig »Gerhart«. Außerdem am Ende der bibl-Angabe Doppelung:
  »SZ-AAP/L1. **SZ-AAP/L1**«. Beides verifiziert.
- **L03641, K1 (Kommentar)**: Rahmentext »ist an den Direktor Adolf Weisse
  **vom Deutschen Volkstheaters** gerichtet« – Kasusmischung, richtig »vom
  Deutschen Volkstheater« oder »des Deutschen Volkstheaters«. Ebenda am Ende
  des Behördenbrief-Zitats »eine Unterschrift ¶ **(unlserl.)**« – wohl
  »(unleserl.)«. Beides verifiziert.
- **L03641, K3 ↔ L03643, K3 (Kommentar-Widerspruch)**: Dieselbe Veranstaltung
  (Bahr-Feier 26. 5. 1913, event pmb296186) wird in L03641 dem »Akademische[n]
  Verein für Kunst und Literatur« (org pmb29767), in L03643 dem »Akademischen
  Verband für Literatur« (org pmb36889) zugeschrieben – zwei verschiedene
  Organisationen. Der NFP-Untertitel (L03643, K4) spricht für »Akademischer
  Verband für Literatur«. Eine der beiden Zuordnungen ist falsch. Zudem in
  L03641, K3 grammatisch: »veranstaltete der Akademische**{r}** Verein« –
  »der Akademische Verein« (so im XML) ist korrekt, aber Organisationsname
  prüfen.
- **L03643, K3 (Kommentar)**: »aus Anlass von Hermann Bahrs 50. Geburtstag am
  **19. 5. 1913**« – Bahr wurde am 19. 7. 1863 geboren, der 50. Geburtstag war
  also der 19. 7. 1913. Auch intern widersprüchlich: L03641, K3 nennt den
  Geburtstag am 26. 5. 1913 noch »bevorstehend«, was mit dem 19. 5. unvereinbar
  wäre. Richtig: »19. 7. 1913«. Verifiziert.
- **L03648, L03650, L03651, L03660, L03776, L03779 (Kommentare, systematisch)**:
  »Aus dem Französischen von Eva und Gerhard **Schwewe**« – die Übersetzer der
  Aufbau-Ausgabe »Von Welt zu Welt« heißen Schewe. Der Fehler steht in allen
  sechs Dateien identisch (kopierte bibl-Angabe) – einmal korrigieren, überall
  nachziehen.
- **L03640, L03656 (Kommentare, systematisch)**: Doppelung der Signatur in
  bibl-Angaben: »SZ-AAP/L1. **SZ-AAP/L1**« (L03640) bzw. zweimal
  »SZ-AAP/L3. **SZ-AAP/L3**« (L03656). Wohl Redundanz aus Titel+idno beim
  Generieren – verifiziert, korpusweit nur diese zwei Dateien betroffen.
- **L03650 (Brieftext)**: In »Hoffentlich ge­lingts!« steckt ein unsichtbares
  weiches Trennzeichen (U+00AD) zwischen »ge« und »lingts« im XML. Sollte
  entfernt werden. Verifiziert.
- **L03651, K2 (Kommentar)**: »um die »**die** innere Uneinigkeit der deutschen
  Geister« international sichtbar zu machen« – doppeltes »die« (Rahmentext +
  Zitatanfang). Richtig: »um ›die innere Uneinigkeit…‹ sichtbar zu machen«.
  Verifiziert.
- **L03651, K3 (Kommentar)**: Die als Übersetzung des französischen Zitats
  eingeleitete Passage beginnt mit einem Satz (»Und wie finden Sie, was unserem
  armen Arthur Schnitzler widerfahren ist?«), der im zitierten französischen
  Text des Briefes gar nicht vorkommt (der beginnt erst mit »Le voici logé…«).
  Übersetzung und Zitat decken sich nicht – prüfen/angleichen.
- **Unaufgelöste »XXXX«-Platzhalter (systematisch, Herzl-Korrespondenz u. a.)**:
  In Kommentaren stehen Platzhalter der Form »XXXX« + Datum, offenbar für
  noch nicht vergebene Brief-IDs (wohl Schnitzlers Gegenbriefe an Herzl):
  L03838 K1 (»XXXX17.11.1894«), L03840 K5 (»XXXX15.12.1894(=vorletzter
  Brief)«), L03841 K2 (»XXXX26.12.1894«), L03843 K6 (»XXXX17.11.1894«),
  L03845 K1 (»XXXX7.1.1895«), L03846 (»XXXX14.1.1895«, »XXXX19.1.1895«),
  L03850, L03851 (je »XXXX18.2.1895«), L03853 (»XXXX8.3.1895«), L03856
  (»XXXX27.3.1895«, »XXXX1.5.1895«), L03877 K1 (»XXXX22.12.1900«), L03893
  (sogar »refXXXX19.1.1895« mit Rest eines ref-Tags im Fließtext). Dazu
  L03757: PMB-bibl mit fehlenden Seitenzahlen »S. XXXX–XXXX«. Diese
  Platzhalter erscheinen im publizierten Text – auflösen oder umformulieren.
  Ferner: L03937 K1 besteht nur aus »XXXX« (leere Kommentar-Anmerkung zu
  »Aussee«), und in L03927 steht im physDesc-Attachment »H1/1925-2, XXXX«.
  **Gravierend**: L04021 K1 enthält eine unfertige redaktionelle
  Arbeitsnotiz im publizierten Kommentar: »Schnitzler vermerkt keine
  Teilnahme von Schwarzkopf. **XXXX CHECK OB ABSAGE VON SCHWARZKOPF**«;
  L04015 K1 hat eine fehlende Seitenzahl (»S. XXXX«). In **L04080 K2**,
  **L04120 K1**, **L04141 K1**, **L04155 K1**, **L04242 K1**, **L04244 K2**
  und **L04252 K1** — sowie zahlreiche weitere in der Schwarzkopf-Korrespondenz
  (u. a. **L04291 K2**, **L04295 K1–K3**) — steht je ein leerer/unfertiger
  Verweis mit anschließendem Platzhalter `[→] XXXX` bzw.
  `<ref type="schnitzler-briefe" target=""/> XXXX` (leeres target;
  L04120: »… XXXX 14.5.1897«; L04155: »[→] XXXX Vermutlich vom 27. 10. 1909«;
  L04252: »[→] XXXX 7.7.1916«). Dieser Platzhalter tritt im L04xxx-Bereich
  gehäuft auf und sollte vor Publikation korpusweit aufgelöst werden.
  In L04026 K2 (nicht XXXX, aber verwandt) ist ein »[→]«-Verweis ohne Ziel.
  (Das `<idno type="handle">XXXX</idno>` im Header aller Dateien ist davon
  zu unterscheiden und wohl beabsichtigt bis zur Handle-Vergabe.)
  Verifiziert.
- **L04111 (Brieftext/Markup)**: In der Aufzählung der Saison-Erfolge steht
  ein doppeltes Komma: »Douloureuse **, ,** Carriére, Snob« – eines
  streichen. Ebenda »**hauptsächlich wegen – hauptsächlich wegen** der
  Familienähnlichkeit« (Schnitzlers Wiederholung, per Faksimile prüfen) und
  die Verschlagwortung »die guten `<rs ref="#pmb50">Wien</rs>er`« (das
  Adjektiv »Wiener« wird fälschlich auf den Ort Wien verlinkt, »er« bleibt
  außerhalb). Markup-Prüffälle.
- **L04318, K3 (Kommentar)**: »die Schnitzler Jahre später in dem Drama
  **Professor Berhardi** aufgehen ließ« – rs-Anzeigetext mit fehlendem n:
  »Professor Bernhardi« (im PMB-Datensatz pmb30203 korrekt). Verifiziert.
- **L04310 (Datierung ↔ K1, Widerspruch)**: Der Brief betrifft eine
  Abschiedsfeier für den Schauspieler Eppens »heute« und ist auf
  **[19. 6. 1903]** datiert (correspAction when="1903-06-19"); K1 gibt aber
  an, Eppens habe »am **19. 6. 1901** seinen letzten Auftritt« gehabt. Beide
  Daten können nicht stimmen – entweder ist die konjizierte Briefdatierung
  falsch (dann 1901) oder K1 (dann 1903). Auflösen.
- **L04526, K1 (Kommentar)**: »Am 17. 8. 1919 kehrte Schnitzler **10 Tagen
  in Reichenau** an der Rax nach Wien zurück« – fehlendes »nach«: »nach
  10 Tagen«. Verifiziert.
- **L04323, K2 (Kommentar)**: »der **weggewofene** Ring habe sich zufällig
  in einem gefangenen Fisch wiedergefunden« – fehlendes r: »weggeworfene«.
  Verifiziert.
- **L04324, K1 (Kommentar)**: »**Es dürfte sich es sich** um eine Gratulation
  … gehandelt haben« – doppeltes »es sich«. Verifiziert.
- **L04296, K1 (Kommentar)**: »**Zwischen 5. 8. 1899 und 5. 8. 1899**
  unternahm Schnitzler … eine Fußwanderung durch Südtirol« – Start- und
  Enddatum identisch (beide Refs auf 1899-08-05); das Enddatum fehlt bzw. ist
  falsch (die Wanderung reichte bis Mitte August, vgl. L04134/L04135:
  Trient am 12. 8., Ischl am 15. 8. 1899). Verifiziert.
- **L04245, K1 (Kommentar)**: »Unklar, ob es sich auch bei der Freundin
  **eine fiktive Gefährtin** handelt« – nach »sich … handelt« fehlt »um«:
  »ob es sich … um eine fiktive Gefährtin handelt«. Verifiziert.
- **L04196 (Brieftext)**: »Karlweis **iſt gleichfalls iſt gleichfalls**
  verſtändigt« – Dublette; ohne textConst-Anmerkung, entweder Schnitzlers
  Verschreiber oder Transkriptionsdopplung. Prüffall Faksimile.
- **L04175, K1 (Kommentar)**: »**Er ist** aller Wahrscheinlichkeit nach vor
  dem 5. 12. 1899 **verfasst sein**« – Verb inkongruent: »Er ist … verfasst
  worden« oder »Er dürfte … verfasst sein«. Verifiziert.
- **L04178, K1 (Kommentar)**: »so dass nur die drei Aufführungen **3. 10.
  1892**, 16. 10. 1902 und 24. 10. 1902 … in Frage kommen« – die erste
  Jahreszahl muss 1902 sein (Die Freundin lief ab 20. 9. 1902; alle drei
  Termine gehören in den Oktober 1902). Ebenda: »hätte also nicht als
  Argument … **herangezogen werden**« – fehlendes »können«. Verifiziert.
- **L04158, K2 (Kommentar)**: »Der Plan wurde nicht **verwirkklicht**« –
  Doppel-k; richtig »verwirklicht«. (Fehlt auch der Schlusspunkt.)
  Verifiziert.
- **L04142, K7 (Kommentar)**: »steht hier als Synonym **for** den
  (institutionellen) Verrat« – richtig »für«. Verifiziert.
- **L04145, K1 (Kommentar)**: »dass die fehlende Beilage nun **das zu
  Absageschreiben** darstellte« – überschüssiges »zu«: »das Absageschreiben«.
  (Im zitierten Berger-Brief zudem »bevor ich über die Annahme schlüssig
  **verden** kann« – wohl »werden«, gegen das Original prüfen.) Verifiziert.
- **L04145, K3 (Kommentar)**: »fand am 14. 3. 1903 **am Volkstheater im
  Volkstheater** statt« – Dopplung (org »Volkstheater« + Ort »Volkstheater«);
  entweder »am Deutschen Volkstheater« oder Ortsangabe streichen. Verifiziert.
- **L04137, K1 (Kommentar)**: »… am betreffenden Tag nicht erwähnt und
  **wird verbringt** Schnitzler den Abend anderweitig« – verunglückte
  Konstruktion: entweder »und verbringt Schnitzler den Abend anderweitig«
  oder »und wird … verbracht haben«. Verifiziert.
- **L04093, K5 (Kommentar)**: Am Ende der Anmerkung klebt ein
  Index-/Personenname ohne Text: »Schnitzler selbst ist darin nicht
  genannt.**Kraus**« – das »Kraus« (rs auf pmb11988) ist ein durchgerutschter
  Registereintrag und gehört entfernt. Verifiziert.
- **L04093, K6 (Kommentar)**: »Die Veranstaltung war **überbucht, dass**
  Leute mit Eintrittskarten abgewiesen werden mussten« – fehlendes »so«:
  »so überbucht, dass«. Verifiziert.
- **L04093 (Brieftext)**: »Manchmal … war ſie vollkommen **irrſinnnig**«
  (drei n) und »**Er folgten** einige recht **hübſcher** Tage« (»Es folgten
  … hübsche Tage«) – ohne textConst-Anmerkung; Schnitzlers Flüchtigkeit oder
  Transkription. Prüffall Faksimile.
- **L04041, K1 (Kommentar, abgebrochener Satz)**: Die Anmerkung endet mitten
  im Satz: »… (23. 11. 1896). **Das Korrespondenzstück wäre demnach**« – der
  Gedanke bricht ab (unfertige Anmerkung). Ergänzen.
- **L04041, K2 (Kommentar)**: »Entsprechend wäre der 23. oder **24. 11.
  1893** ein wahrscheinlicher Termin« – der Brief und beide referenzierten
  Beilagen (Refs auf 1896-11-23 und 1896-11-16) gehören ins Jahr **1896**;
  gemeint »23. oder 24. 11. 1896«. Verifiziert.
- **L04036, K1 (Kommentar)**: Der Brief vom 11. 3. 1906 (ein Sonntag) lädt
  »morgen Montag« ein – das ist der 12. 3. 1906; der Tagebuch-Ref zeigt aber
  auf `target="1906-03-07"` (Mittwoch, 7. 3.). Ziel korrigieren zu
  1906-03-12. Verifiziert.
- **L04026 (Brieftext, Markup)**: »und **von**‹Sonntag› an haben wir den
  Wagen« – vor dem `<date>`-Element fehlt ein Leerzeichen, so dass »von« und
  »Sonntag« im Fließtext zusammenlaufen (»vonSonntag«). Kleinere
  Markup-Korrektur. Verifiziert.
- **L04015, K1 (Kommentar)**: Die Datumsangabe im Zeitungszitat »Illustrirtes
  Wiener Extrablatt, **Jg. 26, Nr. 88, 29. 3. 1899**« ist inkonsistent: Jg. 26
  des Blattes ist 1897 (vgl. L03725: Jg. 29 = 1900), und der Brief samt der
  darin erwähnten Freiwild-Lesung gehört ins Jahr 1897 – gemeint ist also
  »29. 3. 1897«. Verifiziert.
- **L04007, K1 + K2 (Kommentar)**: »reiste er am 16. 7. 1931 an und blieb
  **bist** zum 28. 7. 1931« (→ bis); ebenda K2 »Zuckerkandls Sohn Fritz und
  **seine Frau seine Frau** Gertrude« (doppelt). Verifiziert.
- **L04008, K1 (Kommentar)**: »besuchte er Zuckerkandl zuhause, um ihr zu
  **kondilieren**« – richtig »kondolieren«. Verifiziert.
- **L03995, K4 (Kommentar)**: »den Anspruch auf die französische Krone, den
  in Wien **exilierte Adelsfamilie stellt**« – fehlender Artikel: »den eine
  in Wien exilierte Adelsfamilie stellt«. Verifiziert.
- **L03997, K3 (Kommentar)**: »**FriedrichHofreiter** ist die Hauptfigur von
  Das weite Land« – fehlendes Leerzeichen: »Friedrich Hofreiter«; zudem der
  rs-Verweis fälschlich auf das Werk (pmb30207) statt auf die Person. Ohne
  Schlusspunkt. Verifiziert.
- **L03998 (Brieftext)**: »da mir **ein länger Aufenthalt** Anfangs Juni in
  Paris beschieden sein dürfte« – wohl »ein längerer Aufenthalt«; keine
  textConst-Anmerkung. Prüffall Faksimile.
- **L03999, K1 (Kommentar)**: »hat den Charakter **einer spontane**
  Beileidsbekundung, nicht den **eines Ersatz** für die Teilnahme« – zwei
  Flexionsfehler: »einer spontanen« und »eines Ersatzes«. Verifiziert.
- **L04002 (Brieftext)**: »so tief in die Menschen **hieinzu blicken**« –
  wohl »hineinzublicken«; keine textConst-Anmerkung. Prüffall Faksimile.
- **L03986 (Adresse)**: Anschrift der Karte »Hofrätin Berta **Zuckerkandel**«
  – überall sonst »Zuckerkandl«; falls Schnitzler wirklich »Zuckerkandel«
  schrieb, diplomatisch korrekt, sonst Transkriptionsfehler. Prüffall.
- **L03986, K1 (Kommentar)**: »um … über Rhodos zurück nach **Vedenig** zu
  reisen« – richtig »Venedig« (der rs-Anzeigetext zu pmb462 hat den
  Tippfehler). Verifiziert.
- **L03987 (Brieftext)**: »da wir Krieg u Frieden schmählicher Weise nicht
  **besitzten**« – wohl »besitzen« (oder »besäßen«); keine
  textConst-Anmerkung. Prüffall Faksimile.
- **L03987, K1 (Kommentar)**: Der Brief ist auf den 25. 3. **1915** datiert
  (»ich komme eben vom Anninger«), der Tagebuch-Ref zum Anninger-Ausflug
  zeigt aber auf `target="1912-03-25"` (= 25. 3. **1912**) – drei Jahre
  daneben; gemeint 1915-03-25. Verifiziert.
- **L03977 (Brieftext, Maschinschrift)**: »einen Briefes …, den ich **wieder
  an ihn wieder** zurücksenden musste« – doppeltes »wieder« (eines streichen).
  Verifiziert.
- **L03977, K6 + L03983, K3 (Kommentare, systematisch)**: In beiden Anmerkungen
  Ortsname »Caux und **Terriet**« – der Schweizer Kurort (bei Montreux) heißt
  Territet (so korrekt im Brieftext von L03983/L03985 und im PMB-Datensatz
  pmb52051); das rs-Anzeigetext »Terriet« ist ein Tippfehler. Verifiziert.
- **L03980, K1 (Kommentar)**: »zwischen dem **12. 6.** und dem **17. 06.
  1931**« – inkonsistente Datumsschreibung (mit/ohne führende Null,
  Editionsstandard wäre »17. 6. 1931«). Verifiziert.
- **L03985, K4 (Kommentar)**: »das sie aber erst am Montag, dem 2. 9. 1929
  **besiedeln**« – falsches Verb für ein Hotel; gemeint »beziehen«.
  Verifiziert.
- **L03972, K2 (Kommentar)**: »Gémier wolle ein großes Werk **von ihn**
  aufführen« – richtig »von ihm«. Verifiziert. (Ebenda die Klammer-Dopplung
  »eine nicht (nicht überlieferte) Liste« – ein »nicht« streichen.)
- **L03974 (Adresse)**: Anschrift »Frau Hofrätin Bertha **Zuckerhandl**,
  Wien« – überall sonst »Zuckerkandl«. Verifiziert.
- **L03976, K2 (Kommentar)**: »der Kongress …, der vom **12. bis zum
  16. 1926** in Paris stattfand« – fehlender Monat (der Gründungskongress
  der CISAC fand im Juni 1926 statt): »vom 12. bis zum 16. 6. 1926«.
  Verifiziert.
- **L03960 (Brieftext, Maschinschrift)**: Mehrere Tippfehler ohne
  textConst-Anmerkung: »Ist das ›Weite Land‹ **engültig** erledigt« (endgültig),
  »am **tyrännischen** Meer« (tyrrhenischen), »und wer sich sonst **meine**
  freundlich in Paris erinnert« (meiner … freundlich), Schlussformel »Mit den
  **herzlicnsten** Grüssen« (herzlichsten). Prüffall Faksimile/Durchschlag.
- **L03960, K6 + L03965, K5 (Kommentare)**: In L03960 K6 steht »Die **Die
  Premiere von** Au Perroquet Vert …« (doppeltes »Die«, teils aus dem
  eventName pmb44739 durchgerutscht); in L03965 K5 »Es fand keine Aufführung
  **des des** ›Tapferen Cassian‹« (doppeltes »des«). Verifiziert.
- **L03960, K5 + L03947, K1 (Kommentare, PMB-bibl)**: bibl-Titel »Littérature.
  Comédie **en en act**« (auch in L03947 K1) – doppeltes »en«, zudem »acte«;
  korrekt »Comédie en un acte«. Verifiziert.
- **L03962 (Brieftext)**: Adresszeile »Frau **Hofrät in** Berta Zuckerkandl« –
  Worttrennung mitten in »Hofrätin« (Transkriptionsartefakt). Verifiziert.
- **L03967 (Brieftext)**: »sich in der Frage des **„Reigen«**« – öffnendes
  Anführungszeichen „ (unten) statt » (Guillemet), inkonsistent mit dem
  schließenden «. Verifiziert.
- **L03957 (Brieftext, Maschinschrift)**: »halte ich … ›Die grosse Szene‹
  für den **wirkamsten**« (wirksamsten) und im Nachsatz »dass ich Mme Maury
  **keinerlei keine** bestimmte Autorisation erteilt hatte« (Doppelung) –
  keine textConst-Anmerkungen. Prüffall Faksimile.
- **L03957, K8 (Kommentar)**: »der für den Verlag **Rieder e Cie**« – der
  PMB-Datensatz (pmb299399) lautet korrekt »F. Rieder et Cie«; das »et«
  ergänzen. Verifiziert.
- **L03958 (Brieftext, Maschinschrift)**: »die gestern **beprochene**
  Liste« – wohl »besprochene«; keine textConst-Anmerkung. Prüffall.
- **L03959, K5 (Kommentar)**: »reiste am 17. 6. 1925 … nach Baden-Baden und
  … am `<ref target="1925-07-22"/>` nach München. Am 23. 6. 1925 traf er …
  Pollaczek …, bevor er am 4. 7. 1925 nach Wien zurückkehrte« – der
  München-Ref (22. **7.**) sprengt die Chronologie; gemeint ist der
  **22. 6. 1925**. Verifiziert.
- **L03944, K4 (Kommentar)**: »Schnitzlers Vater war am
  `<ref target="1894-05-02"/>` verstorben« – Johann Schnitzler starb am
  **2. 5. 1893** (so korrekt in L03827, K1 und L03898, K2); der Brief selbst
  stammt vom 13. 6. 1893. Ref-Ziel und Text korrigieren. Verifiziert.
- **L03945, K1 (Kommentar)**: Die Beilage (Brief der Frau Lefèvre) wird als
  »datiert mit **5. 1. 1913**« beschrieben – der vorliegende Brief stammt
  aber vom 8. 1. **1912** (die zitierte NWJ-Notiz in K4 ist vom 6. 1. 1912).
  Entweder Tippfehler für 1912 oder (falls die Vorlage wirklich 1913 trägt)
  erklärungsbedürftig; vgl. L03951, K1, wo derselbe CUL-Brief mit 5. 1. 1913
  genannt wird. Prüffall.
- **L03945 (Brieftext, Maschinschrift)**: »derjenige der sich auf seine
  **persönlichen zu Guitry** berief« – fehlendes Substantiv (»Beziehungen«);
  keine textConst-Anmerkung. Prüffall Faksimile.
- **L03946, K4 (Kommentar)**: bibl »An **Examniation** of Power **an**
  Translation« – richtig »Examination … and« (so korrekt in K5 derselben
  Datei). Verifiziert.
- **L03947 (Brieftext, Maschinschrift)**: »Ihre **Teilaberschaft** begänne«
  – wohl »Teilhaberschaft«; keine textConst-Anmerkung. Prüffall. Außerdem
  einmal deutsche Anführungszeichen im Lauftext („Lebendige Stunden") statt
  der sonst verwendeten »«-Guillemets – vereinheitlichen bzw. als Befund der
  Vorlage kennzeichnen. Verifiziert.
- **L03948, K3/K8 + L03949, K1 (Kommentare)**: »**Arthug** Schnitzler an
  Paul Géraldy« (→ Arthur); »die **Bedigungen** … erläutert« und »die
  **urspünglich** vereinbarte Frist« (L03948, K8) sowie nochmals »die
  finanziellen **Bedigungen**« (L03949, K1) – Bedingungen/ursprünglich.
  Verifiziert.
- **L03950, K1 (Kommentar)**: »Ein Exemplar ist im **Nachlas** Schnitzlers«
  – »Nachlass«. Verifiziert.
- **L03938 (Brieftext)**: »aus den von Ihnen **gekaſten** … künſtleriſchen
  Gründen« – wohl »gekannten«; ebenda »und Sie, lieber Doctor **sollen
  Gele­genheit, 6 Wochen lang Gelegenheit**, … klar u ſchlüſſig zu werden« –
  doppeltes »Gelegenheit« und fehlendes Verb (»hatten«?). Keine
  textConst-Anmerkungen. Prüffall Faksimile.
- **L03939 (Brieftext)**: »mit einigem **Ummuth**« (Unmuth) und
  Schlussformel »**Getunlichſt** grüßend« (kein Wort; »Getreulichſt«?
  »Thunlichſt«?) – keine textConst-Anmerkungen. Prüffall Faksimile.
- **L03943, K1 (Kommentar)**: Glosse zu »p. r.« lautet »**pro recipiendo
  (lateinisch): für den Empfang**« – auf Visitenkarten steht p. r. für
  französisch »**pour remercier**« (als Dank), das passt auch zum Kontext
  (»das kühle p. r., das für alle iſt«). Verifiziert.
- **L03927 (Beilage)**: Im transkribierten Müller-Guttenbrunn-Brief: »der
  man weder die **Natürkichkeit** … abſprechen kann« – wohl »Natürlichkeit«;
  keine textConst-Anmerkung. Prüffall Faksimile.
- **L03929 (Brieftext/Beilage)**: »**Seien die** vielmals herzlich gegrüßt«
  – wohl »Seien Sie«; in der Beilage (Müller-Guttenbrunn, 9. 4. 1895) zudem
  »am **beſen** wiſſen, was er**,** thun darf« (besten; störendes Komma) und
  »**Ihr** Anfrage« (Ihre). Keine textConst-Anmerkungen. Prüffall Faksimile.
- **L03932 (Brieftext)**: »Einſamkeit und **Begeiſterrung**« – doppeltes r;
  keine textConst-Anmerkung. Prüffall Faksimile.
- **L03933 (Datierung, Anmerkung fehlt)**: Der Brief ist auf den 16. 5. 1895
  datiert (Titel/correspAction), das nachgestellte Datum im Postskript
  lautet aber »**16/10 95**«. Inhaltlich passt Mai (»Aufführung für März
  versprochen«, »komme heuer nicht mehr dran« – die Liebelei-UA war am
  9. 10. 1895 bereits vorbei). Entweder Transkriptionsfehler oder
  Schreibirrtum Schnitzlers – in beiden Fällen fehlt eine Anmerkung.
  Verifiziert.
- **L03934, K1 (Kommentar)**: »zu den Ostersonntagausgaben der **Neuen
  Freie** Presse« – »Neuen Freien Presse«; ebenda »lassen sich auf kaum
  einen … **anuwenden**« – »anwenden«. Verifiziert.
- **L03922, K1 (Kommentar)**: »so dass dies der letzte Zeitpunkt wäre,
  **indem** das vorliegende Korrespondenzstück verfasst sein kann« –
  richtig »in dem« (bzw. »zu dem«). Verifiziert.
- **L03924 (Brieftext)**: »daſs Sie ſich dem Director ſelbſt gegenüber **zu
  neuen** geneigt wären« – wohl »zu nennen«; keine textConst-Anmerkung.
  Prüffall Faksimile.
- **L03926 (Brieftext)**: »den Brief in einer Abſchrift an ihn
  **gelangen. zu laſſen**« – Punkt mitten im Satz (Transkriptionsartefakt?);
  ebenda »gebe nur zu **bedeken**« (bedenken). Keine textConst-Anmerkungen.
  Prüffall Faksimile.
- **L03909–L03913 (Brieftexte, Schnitzler-Handschrift, Sammel-Prüffall)**:
  Auffällige Formen ohne textConst-Anmerkung – Schnitzlers Flüchtigkeit oder
  Transkriptionsfehler, jeweils gegen das Faksimile zu prüfen: L03909 »zur
  Vollendung **Ihrer** Stückes« (Ihres) und »an das andere Theater
  **weiterbeförden**« (weiterbefördern); L03910 »daſs ein ſo hochſtehender
  Menſch wie Jacob **ihn** heiratet« (sie, d. i. Hermine) und »laſſen
  **die** Ihren Helden nicht ſo ergeben ſterben« (Sie); L03911 »die Kraft
  zu der ganzen **Tragöde**« (Tragödie) und »theatraliſch **unangehm**«
  (unangenehm; vgl. »unangehehm« L03837); L03913 »daſs ein guter
  **Schreiben** dieſelben Dienſte thut« (Schreiber).
- **L03915, K1 (Kommentar)**: »**Schnitzlers Wunsch wurde** am 5. 5. 1896
  **Folge geleistet**« – Dativ fehlt: »Schnitzlers Wunsch wurde …
  entsprochen« oder »Dem Wunsch Schnitzlers wurde … Folge geleistet«.
  Verifiziert.
- **L03916, K1 (Kommentar)**: Parenthese nicht geschlossen: »durch den
  Inhalt – die für die Zeitung ungewöhnliche Länge von Lieutenant Gustl
  **in den Zeitraum** …« – nach »Gustl« fehlt der zweite Gedankenstrich.
- **L03917, K1 (Kommentar)**: Intern widersprüchlich: Erst werden die zwei
  möglichen Zeiträume mit »**26.–28. April** und 2.–5. Mai« angegeben, zwei
  Sätze später heißt das »vorletzte Wochenende« aber »(Donnerstag, **25.**
  bis Sonntag, 28.)« – 25. oder 26. April als Beginn vereinheitlichen
  (der Donnerstag war der 25. 4. 1889). Verifiziert.
- **L03901 (Brieftext)**: Mehrere auffällige Stellen ohne textConst-Anmerkung:
  »**wie** ſpazierten an einem Spätherbſtabende … auf u ab« (wohl »wir«),
  »etwas **hervorrragendes**« (drei r), »Sie iſt aber ſo wahrſcheinlich,
  daſs **Sie** alle Welt für erfunden hält« (wohl »ſie«, die Geſchichte),
  »der den Namen »**Theoder** Herzl« ausſpricht« (wohl »Theodor«, ggf.
  Schnitzlers Versehen). Prüffall Faksimile.
- **L03905 (Brieftext)**: Anrede »Mein **verehrtes** Freund« – wohl
  »verehrter« (oder Schnitzlers Versehen, dann Anmerkung); ebenso L03907
  »Mein **verehrte** Freund«. Keine textConst-Anmerkungen. Prüffall
  Faksimile.
- **L03906 (Brieftext)**: »Ich ging ſchwer **gekränktens** davon« – wohl
  »gekränkt« (überschüssiges »ens«); keine textConst-Anmerkung. Prüffall
  Faksimile.
- **L03893, K1 (Kommentar)**: »Das Original des Telegramms **nicht
  erhalten**« – fehlendes »ist«; ebenda »die sich in der **Österreichische**
  Gesellschaft für Literatur (Wien) befindet« – »Österreichischen«.
  Verifiziert.
- **L03895, K3 (Kommentar)**: Zum Brief vom 12. 9. **1893** ist das
  zufällige Kaffeehaus-Treffen mit `<ref type="schnitzler-tagebuch"
  target="1895-09-18"/>` (= 18. 9. **1895**) belegt – zwei Jahre daneben;
  gemeint wohl 1893-09-18. Ref-Ziel prüfen/korrigieren. Verifiziert.
- **L03896 (Brieftext)**: Drei auffällige Formen ohne textConst-Anmerkung:
  »Wochen der ungeheuerlichsten **Poduktionsaufregung**« (Produktions-;
  r-Ausfall-Klasse), »an der **munitiösen** Ausführung« (minutiösen?) und
  »wenn wir im Sommer im Salzkammergut **Z**usammentreffen« (Verb groß).
  Prüffall Faksimile.
- **L03899, K2 (Kommentar)**: »In diesem Jahr fiel der Ostersonntag auf den
  **7. 4. 1901**« – der Brief stammt vom 28. 2. **1902**; Ostersonntag 1902
  war der **30. 3. 1902** (der 7. 4. war Ostern 1901). Verifiziert.
- **L03876 (Brieftext)**: »denn sie würde uns durch **ihr** Länge das ganze
  Blatt sprengen« – wohl »ihre Länge« (Herzls Flüchtigkeit oder
  Transkription); keine textConst-Anmerkung. Prüffall Faksimile.
- **L03884, T1 (textConst-Anmerkung)**: »Durch Umstellungszeichen geändert
  aus: ›ungefähr nach **jendem** Blatt‹« – im Brieftext steht »jenem«; das
  d in der zitierten Ursprungsfassung ist wohl ein Transkriptionsfehler.
  Prüffall Faksimile.
- **L03887, K4 (Kommentar)**: Im Zitat aus Heinrich Schnitzlers Edition wird
  das Binnenzitat mit »›…es gibt auch dichterische Begabungen…« eröffnet,
  aber mit »…angehören…**«**« statt mit »‹« geschlossen –
  Anführungszeichen-Ebenen geraten durcheinander. Verifiziert.
- **L03873 (Brieftext)**: Schlussformel »Mit herzlichen **Grüsse** / Ihr
  ergebener« – wohl »Grüssen« (Herzls Flüchtigkeit oder Transkription);
  keine textConst-Anmerkung. Prüffall Faksimile.
- **L03875, K1 + L04230, K2 + L02937 (Kommentare, rs-Anzeigetext,
  systematisch)**: Der Werktitel wird mehrfach »**Lieutnant** Gustl«
  geschrieben (fehlendes e; korrekt »Lieutenant Gustl«): L03875 K1 (dort im
  selben Kommentar sonst richtig), L04230 K2 und L02937 – jeweils als
  rs-Anzeigetext zu pmb29853. Verifiziert.
- **L03881 (Adresse/Bildaufdruck)**: Vorgedruckter Kartentext »Kuhrische
  **Nerhrung**« – wohl »Nehrung« (Transkription des Aufdrucks prüfen; betrifft
  auch rs pmb298443). Prüffall Faksimile.
- **L03867, K2/K3 (Kommentar)**: Drei Fehler: »**Das sich abkühlenden**
  Verhältnis« (→ abkühlende), »und **zulgleich** weiterem Befremden«
  (→ zugleich), bibl »**Unveröffentliche** autobiografische Aufzeichnungen«
  (→ Unveröffentlichte; auch PMB-Werktitel pmb298897 prüfen). Verifiziert.
- **L03855, K1 (Kommentar)**: »Besuch der Aufführung der Operette **die
  Billanten-Königin**« – wohl »Die Brillanten-Königin« (fehlendes r; Artikel
  klein). Titel prüfen, verifiziert im XML.
- **L03856, K1 (Kommentar)**: »Leopold von **Andrian-Werbung**« – die
  Familie heißt »Andrian-Werburg«. Verifiziert.
- **L03860, K2 (Kommentar)**: »Die Figur **des Rittmeister von Schramms**« –
  Genitiv verrutscht: »des Rittmeisters von Schramm«. Verifiziert.
- **L03846, K1 (Kommentar)**: »Um das **Inkongito** seiner Verfasserschaft
  **am Schauspiels** Das neue Ghetto … abzusichern« – »Inkognito« und »am
  Schauspiel« (bzw. »an dem Schauspiel«). Verifiziert.
- **L03846, K3 (Kommentar)**: »das **franzöische** Kabinett« – richtig
  »französische«. Verifiziert.
- **L03848 (Brieftext)**: »in unserer **Geheimnisikrämerei**« – wohl
  »Geheimniskrämerei« (oder Herzls Verschreiber); keine textConst-Anmerkung.
  Prüffall Faksimile.
- **L03851, K4 (Kommentar)**: »aufgrund der aus den Pariser Zeitungen
  **widergegebenen** … Töne« – richtig »wiedergegebenen«. Verifiziert.
- **L03837, K3 + L03851, K3 + L03854, K1 (Kommentare, systematisch)**:
  dreimal dieselbe Fehlerklasse: »**postitive** Neubewertung« (L03837),
  »nicht nur **postitive** Töne« (L03851), »eine **postive** Besprechung«
  (L03854) – jeweils »positive«. Verifiziert (korpusweit sonst keine
  weiteren Vorkommen).
- **L03853, K1 (Kommentar)**: »Daraus ergibt sich der 17. 3. 1895 **als
  letzten Tag** der Vorwoche vor der Abreise **als hinteres Datum** der
  Zeitspanne« – Kasus (»als letzter Tag«) und doppeltes »als …« – Satz
  umbauen.
- **L03854, K2 (Kommentar)**: Der angekündigte Besuch »Dienstag Vormittag«
  ist mit `<ref type="schnitzler-tagebuch" target="1895-03-21"/>` versehen –
  der 21. 3. 1895 ist aber der (Donnerstags-)Absendetag des Briefes; der
  angekündigte Dienstag nach der Ankunft (Montag, 25. 3.) wäre der
  **26. 3. 1895**. Ref-Ziel prüfen/korrigieren. Verifiziert.
- **L03837 (Brieftext)**: Mehrere auffällige Formen ohne textConst-Anmerkung:
  »**mancke** Stellen« (manche), »der letzte Akt einer **Tragodie**«,
  »**zuruckhält**«, »**unangehehm**« – Herzls Flüchtigkeit oder
  Transkriptionsfehler. Prüffall Faksimile.
- **L03838, K2 (Kommentar)**: »dieses wiederum sollte es an das Neue Theater
  **und** weitergeben und **schließliche** an die Freie Bühne« –
  überschüssiges erstes »und« sowie »schließlich«. Verifiziert.
- **L03843 (Beilage, Anmerkung fehlt)**: Die zitierte »Vorbemerkung für den
  Director« ist unterzeichnet »Wien am 4 Januar **1894**« – gemeint ist 1895
  (Neujahrs-Verschreiber Herzls); eine Anmerkung fehlt. Verifiziert.
- **L03843, K2 (Kommentar)**: »die **allerings** in der Druckfassung« –
  richtig »allerdings«. Verifiziert.
- **L03845, K3 (Kommentar)**: »Theodor Herzl: Das **Parlais** Bourbon« – der
  rs-Text verschreibt den Titel; der PMB-Datensatz (pmb298564) hat korrekt
  »Das Palais Bourbon«. Verifiziert.
- **L03829, K1 (Kommentar)**: »enthält … eine **Reflektion** über Herzls
  Selbstverständnis« – standardsprachlich »Reflexion«. Verifiziert.
- **L03830, K9 (Kommentar)**: »der Schauspieler Alexander **Giradi**« –
  richtig »Girardi« (so auch im anschließenden Zeitungszitat derselben
  Anmerkung). Verifiziert.
- **L03830, K4 (Kommentar)**: Im Zeitungszitat steht »wäre im Stande
  **gewesen gewesen**, das Interesse … abzuschwächen« – Doppelung; gegen den
  Erstdruck prüfen (falls dort so, »[sic]« erwägen; sonst
  Transkriptionsfehler). Prüffall.
- **L03835 (Brieftext)**: »so geht das Stück ans Berliner dann **aus** Neue
  Theater« – wohl »ans Neue Theater«; keine textConst-Anmerkung. Prüffall
  Faksimile.
- **L03835, K1 (Kommentar)**: »und die im Anschluss **daran darauf**
  angestrebte Drucklegung« – eines der beiden Wörter streichen. Verifiziert.
- **L03836 (Datierung, Anmerkung fehlt)**: Die Dateline lautet »Paris
  **8 November 894**«, Titel und correspAction datieren auf den
  **13. 11. 1894** – vermutlich zu Recht (der Brief antwortet auf L03835 vom
  8. 11.), aber anders als bei vergleichbaren Fällen (z. B. L03825) fehlt
  jede Anmerkung zur abweichenden/irrtümlichen Datierung Herzls. Ergänzen.
  Verifiziert.
- **L03836 (Brieftext)**: Im zitierten Direktorenbrief: »Wer ein Stück
  **abdehnt**, soll dafür einstehen« – wohl »ablehnt«; keine
  textConst-Anmerkung. Prüffall Faksimile.
- **L03820, K2 (Kommentar)**: »Im gleichen Schreiben dürfte er auch zur
  Promotion **geladen**, die am Folgetag, dem 30. 5. 1885 stattfand« –
  fehlendes »haben« (»geladen haben«); zudem fehlt das schließende Komma der
  Apposition (»dem 30. 5. 1885,«). Verifiziert.
- **L03822, K1 (Kommentar)**: Dreimal falsches Jahr: »die am 2. 10. **1896**
  hätte stattfinden sollen«, »das wäre der 4. 10. **1896** gewesen«, »Herzl
  reiste am 3. oder 4. 10. **1896**« – der Brief und die Ereignisse
  (Lindaus »Maria und Magdalena«, Josephine Wessely) gehören ins Jahr
  **1886**; die vierte Datumsangabe (»bis zum 21. 10. 1886«) ist korrekt.
  Verifiziert.
- **L03823, K2 (Kommentar)**: Übersetzung des Baudelaire-Zitats »ô toi qui le
  savais« mit »Du **hättest** es gewusst« – das französische Imperfekt ist
  indikativisch: »der du es wusstest« (nur »j’eusse aimé« ist Konjunktiv).
  Verifiziert.
- **L03825, K3 (Kommentar + PMB pmb18870)**: Herausgeber »**Jaques** Joachim«
  – üblich »Jacques Joachim«; die Schreibung ohne c steht auch im
  PMB-Personendatensatz. Prüfen (Selbstschreibung?) und ggf. korrigieren.
- **L03826, K2 (Kommentar)**: »Bestechungen von **Abgeordenten**« – richtig
  »Abgeordneten«. Verifiziert.
- **L03811, K2 (Kommentar)**: »eine freie Neubearbeitung der klassischen
  **Kommödie** von Ben **Johnson**« – »Komödie« mit einem m; der Dramatiker
  heißt »Jonson« (so korrekt in K1 und K3 derselben Datei). Verifiziert.
- **L03811, K3 (Kommentar)**: Zwei aufeinanderfolgende Sätze beginnen mit
  »Hier« (»Hier findet sich Volpone … Hier wäre alphabetisch …«) –
  stilistisch glätten.
- **L03812, K3 (Kommentar)**: »Der erste öffentliche Auftritt von Olga
  Schnitzler als **Sängering**« – richtig »Sängerin«. Verifiziert.
- **L03815, K1 (Kommentar)**: »die Internationale Klinische Rundschau
  herausgab (**1897–1894**)« – unmögliche Spanne; gemeint wohl
  »1887–1894«. Verifiziert.
- **L03815, K3 (Kommentar)**: »dürfte das **tatsächlich versandte**
  inhaltlich nicht stark abgewichen haben« – Substantivierung groß (»das
  tatsächlich Versandte«) oder Bezugswort ergänzen (»das tatsächlich
  versandte Schreiben«). Verifiziert.
- **L03816, K1 (Kommentar)**: »Schnitzler könnte die Kontaktaufnahme durch
  Sendung von … angestoßen haben, **der** sich dafür mit dieser
  **Vistenkarte** samt Beilage revanchierte« – erstens Visitenkarte;
  zweitens hängt das Relativpronomen »der« grammatisch an Schnitzler,
  gemeint ist aber Freud (»worauf sich Freud … revanchierte«). Verifiziert.
- **L03805, K1 (Kommentar)**: »für den angesprochenen Donnerstag – **dem**
  2. 12. 1909 –« – Apposition im falschen Kasus: »den 2. 12. 1909«.
  Verifiziert.
- **L03798, K1 (Kommentar)**: Zwei aufeinanderfolgende Sätze beginnen mit
  »Jedenfalls« (»Jedenfalls dürfte dadurch … Jedenfalls war zu diesem
  Zeitpunkt …«) – stilistisch glätten.
- **L03799 (Adresse, Annotation fehlt)**: Schnitzler adressiert wieder
  irrtümlich »Wien **I** Kochgasse 8« (Zweig wohnte im 8. Bezirk). In L03792
  ist derselbe Fehler mit K-Anmerkung (»Schreibirrtum«) versehen, hier fehlt
  sie; zudem ist das falsche »Wien I« per rs auf pmb51 (Innere Stadt)
  verlinkt. Vereinheitlichen (Anmerkung ergänzen bzw. Verlinkung überdenken).
  Verifiziert.
- **L03786 (Brieftext)**: »ein einziges Exemplar **meines neues** Buches« –
  wohl »meines neuen« (oder Schnitzlers Flüchtigkeit); ebenda »ein Mangel,
  der sich **andrer Stelle** finden mag« – fehlendes »an«. Beides ohne
  textConst-Anmerkung. Prüffall Faksimile.
- **L03774, K3 (Kommentar)**: »ihre Ehe mit Felix Adolf von **Wintenitz**
  **annulieren**« – erstens fehlt das r: »Winternitz« (so unmittelbar davor
  bei Friderike; betrifft auch die rs-Anzeige zu pmb298330); zweitens
  »annullieren« mit Doppel-l. Verifiziert.
- **L03774 (Beilage, Maschinschrift)**: »nur mehr eine ganz **enfernte**
  Aehnlichkeit« – wohl »entfernte«; keine textConst-Anmerkung. Prüffall
  Faksimile.
- **L03777 (Brieftext)**: »einer Karte an mich …, die hier … für mich
  aufbewahrt **lagen**« – Singular »lag« wäre korrekt; Schnitzlers Versehen
  (Anmerkung erwägen) oder Transkriptionsfehler. Prüffall Faksimile.
- **L03780 (Brieftext)**: »Ihre Bedenken hinsichtlich **der** Schlusses« –
  wohl »des Schlusses«; keine textConst-Anmerkung. Prüffall Faksimile.
- **L03780, K5 ↔ L03643, K4 (Kommentar-Widerspruch + PMB)**: Dieselbe
  NFP-Publikation von Zweigs Bahr-Rede wird in L03780 mit »Nr. 17.513,
  **13. 5. 1913**«, in L03643 mit »Nr. 17.513, **27. 5. 1913**« zitiert. Da
  die Rede am 26. 5. 1913 gehalten wurde, ist der 27. 5. richtig; der
  13. 5. steht auch im PMB-Werkdatensatz (werk_bibliografische-angabe in
  beiden Dateien) und muss dort ebenfalls korrigiert werden. Verifiziert.
- **L03757, K3 (Kommentar)**: »erschienen bereits in Auszügen in **mehren**
  Zeitungen und Zeitschriften« – richtig »mehreren«. Verifiziert.
- **L03759 (Brieftext)**: »meine liebe Hofrätin erzält mir heute Abend, dass
  **Sie** Ihnen … berichtet hat« – das großgeschriebene »Sie« müsste sich auf
  die Hofrätin beziehen (»dass sie Ihnen berichtet hat«); wenn Olga
  Schnitzler wirklich »Sie« schrieb, Anmerkung erwägen. Prüffall Faksimile.
- **L03759, K1 (Kommentar)**: Schlusssatz »Eventuell könnte es sich auch um
  ein spezifischeres Gerücht handeln, **Olga Schnitzler in einer intimen
  Beziehung vermutend**« – verunglückte Partizipialkonstruktion; gemeint
  wohl: »…, das Olga Schnitzler eine intime Beziehung unterstellte«.
  Verifiziert. (Davor auch stilistisch holprig: »hatte es schwer und tat
  sich schwer«.)
- **L03761 (Brieftext)**: Unterschrift »Arthur **Schnitzer**« – fehlendes l;
  keine textConst-Anmerkung. Prüffall Faksimile (vgl. »ArthurSchitzler«
  L03747).
- **L03762 (Brieftext)**: »wegen der **Versteigung**« – wohl »Versteigerung«
  (Schnitzlers Auslassung oder Transkriptionsfehler); keine
  textConst-Anmerkung. Prüffall Faksimile.
- **L03762, K3 (Kommentar)**: Glosse zu »frondiren« lautet »**schaf** gegen
  etwas opponieren« – richtig »scharf«. Verifiziert.
- **L03763, K3 (Kommentar)**: Signatur »DLA Marbach, **HS.NZ85.1.1911,1**« –
  wohl »HS.1985.1.1911,1« (alle übrigen Marbach-Signaturen im Korpus lauten
  HS.1985.…). Verifiziert.
- **L03764, K2 (Kommentar)**: »im Verlag Schuster **& und** Loeffler« – im
  XML steht das Kaufmanns-Und (`<c rendition="#kaufmannsund"/>`) **plus**
  ausgeschriebenes »und«; eines von beiden ist zu streichen. Verifiziert.
- **L03747 (Brieftext)**: Eigenhändige Unterschrift (nach handShift)
  »**ArthurSchitzler**« – fehlendes n; entweder tatsächlich so gekritzelt
  (dann ggf. Anmerkung) oder Transkriptionsfehler. Prüffall Faksimile.
- **L03747, K2 (Kommentar + PMB pmb195350)**: Das Zitat »In deiner Brust sind
  deines Schicksals Sterne« steht nicht in **Wallensteins Tod**, sondern in
  **Die Piccolomini** (Illo zu Wallenstein, 2. Aufzug, 6. Auftritt). Auch der
  rs-/PMB-Verweis (pmb195350 »Wallensteins Tod«) zielt entsprechend auf das
  falsche Teilstück der Trilogie. Prüffall/korrigieren.
- **L03751 (Brieftext)**: »Ich **freu mit** sehr.« – wohl »freu mich«; keine
  textConst-Anmerkung. Prüffall Faksimile.
- **L03753, K2 (Kommentar)**: »befindet sich der Durchschlag eines Briefes an
  Hella, **das** mit dem **Vortag** datiert ist« – erstens Relativpronomen:
  »der« (Durchschlag/Brief); zweitens ist der anschließend zitierte
  Durchschlag mit **19. 2. 1923** datiert – das ist nicht der Vortag des
  vorliegenden Briefes vom 22. 1. 1923, sondern vier Wochen später. Datum
  oder Formulierung korrigieren. Verifiziert.
- **L03738 (Brieftext)**: »das ich natürlich partienweise schon **kannnte**«
  – dreifaches n; zudem wird die öffnende Klammer vor »das ich« nie
  geschlossen. Keine textConst-Anmerkung. Prüffall Faksimile. Ebenso zu
  Beginn: »ich danke **Ihren** und Ihrer verehrten Gattin« – wohl »Ihnen«
  (oder Schnitzlers Versehen, dann Anmerkung erwägen).
- **L03738, K3 (Kommentar)**: »keine weiteren **persönliche** Treffen« –
  richtig »persönlichen«. Verifiziert.
- **L03739 (Brieftext)**: Im Telegramm steht in der Unterschrift
  `<signed>schnitzler ‹«</signed>` – die Zeichen »‹«« sind offenkundig
  Transkriptionsreste und gehören entfernt (oder als Druckzeichen des
  Formulars ausgewiesen). Verifiziert.
- **L03743, K2 (Kommentar)**: Glosse zu »z. E.« lautet »**zum Einen**« –
  falsch aufgelöst: »z. E.« steht für »**zum Exempel**« (= zum Beispiel).
  Verifiziert.
- **L03745, K1 (Kommentar)**: »Der Verlag **Wremla**« – richtig »Wremja« (so
  der PMB-Datensatz pmb294981 und die Kommentare in L03687/L03688).
  Verifiziert. Ebenda: die beiden Novellen erschienen »unter dem Titel
  **Smjatenie Chusto**« (auch PMB-Werktitel pmb295117) – die russische
  Transliteration von »Смятение чувств« wäre »Smjatenie čuvstv« (bzw.
  »Smjatenie tschuwstw«); »Chusto« wirkt verstümmelt. Prüffall/PMB.
- **L03746, K2 (Kommentar)**: »erschienen zwei Texte **in der Neue Freie
  Presse**« – Titel undekliniert nach Präposition; entweder »in der Neuen
  Freien Presse« oder Umstellung (»in: Neue Freie Presse«).
- **L03729, K1 (Kommentar)**: In der Rezensions-bibl »Münchner neueste
  Nachrichten, Jg. 68, Nr. 610, S. 2« fehlt das Erscheinungsdatum (sonst
  Standard in den bibl-Angaben der Edition; auch im PMB-Datensatz so).
- **L03730 (Brieftext)**: »In der **Hälften** des zweiten Actes« – wohl
  »Hälfte«; keine textConst-Anmerkung. Prüffall Faksimile.
- **L03737 (Brieftext)**: »bald nachdem Sie **eingetroffenen** sind« – wohl
  »eingetroffen«; keine textConst-Anmerkung. Prüffall Faksimile
  (Schnitzler-Handschrift).
- **L03720 (Brieftext)**: »Wenn ich mir erlauben darf, eine **Meiung** zu
  äußern« – wohl »Meinung«; keine textConst-Anmerkung. Prüffall Faksimile.
- **L03724, K2 (Kommentar)**: »Ein paar Wochen später, **am 28. 2. 1900
  meldeten** mehrere Tageszeitungen« – schließendes Komma der Apposition
  fehlt: »am 28. 2. 1900, meldeten«.
- **L03725, K1 (Kommentar)**: In der bibl-Angabe »(**Illustrierte** Wiener
  Extrablatt, Jg. 29, Nr. 57, 28. 2. 1900, S. 12)« fehlt das Flexions-s des
  Titels: »Illustriertes Wiener Extrablatt« (bzw. historisch »Illustrirtes«).
  Der Lauftext davor (»Das Illustrierte Wiener Extrablatt gab bekannt«) ist
  dagegen korrekt dekliniert. Verifiziert.
- **L03728, K2 (Kommentar)**: »und zu einem **persönliches** Treffen wenige
  Tage darauf« – richtig »persönlichen«. Verifiziert.
- **L03710, K2 (Kommentar + PMB pmb113878)**: »**Henning von Brüsewicht**
  hatte in der Nacht von 11. auf den 12. 10. 1896 … einen Zivilisten
  ermordet« – der Leutnant der Karlsruher Affäre hieß **von Brüsewitz**;
  »Brüsewicht« im Brieftext ist wohl Plessners Wortspiel (Anklang an
  »Bösewicht«) und sollte nicht als Namensform in Kommentar und
  PMB-Personendatensatz übernommen werden; Vorname prüfen. Außerdem:
  »in der Nacht **von 11.**« → »vom 11.«.
- **L03710, K3 (Kommentar)**: Glosse zu »pitoyablen« lautet nur
  »bemitleidenswerten« – ohne die sonst übliche Sprachangabe
  (»französisch: …«). Vereinheitlichen.
- **L03713, K2 (Kommentar)**: »Ihr … Tagebuch wurde postum **publiziert ein
  vielbeachtetes Buch**« – Satzbau verunglückt; etwa: »wurde postum
  publiziert und war ein vielbeachtetes Buch« oder »wurde, postum publiziert,
  ein vielbeachtetes Buch«. Verifiziert.
- **L03718, K2 (Kommentar)**: »in ein **Taubstummes** Mädchen verliebt« –
  Adjektiv klein: »taubstummes«. Verifiziert.
- **L03719 (Brieftext)**: »ist mir doch ein bisschen **aus Herz** gewachsen«
  – wohl »ans Herz«; keine textConst-Anmerkung. Prüffall Faksimile.
- **L03701 (Datierung, Titel ↔ Brieftext/Kommentar)**: Die Dateline lautet
  »den **14.** 9. 96«, Titel und correspAction datieren aber auf den
  **15. 9. 1896** (n="02", d. h. als zweiter Brief des Tages neben L03702).
  K3 sagt jedoch: »**Bereits am Folgetag** fand das erste persönliche
  Zusammentreffen statt, 15. 9. 1896« – der Folgetag eines Briefes vom 15. 9.
  wäre der 16. 9. Entweder ist die Datierung auf den 15. 9. falsch (dann
  wohl 14. 9. 1896) oder K3 muss umformuliert werden (»noch am selben Tag«).
  Verifiziert; zudem fehlt eine Anmerkung, die die Abweichung der Dateline
  erklärt.
- **L03701, K1 + PMB pmb296028 (systematisch)**: »hatte Elsa Plessner
  Schnitzler **ihre** Schauspiel **Heimkehr** … gesandt« – erstens »ihr
  Schauspiel«; zweitens heißt das Stück »**Heimweh**«: so nennt es Plessner
  selbst im Brieftext (L03708, L03713), ebenso die Kommentare in L03698,
  L03703, L03708. Der PMB-Werkdatensatz pmb296028 führt aber als Haupttitel
  »Heimkehr [dreiaktige Tragikomödie]« – dieser falsche Titel steht in den
  back-Daten von zehn Dateien (L03698, L03701, L03703–L03705, L03708, L03709,
  L03712, L03713, L03722). In der PMB korrigieren. Verifiziert.
- **L03700, K3 (Kommentar)**: Inkonsistente bibl-Angaben in einer Anmerkung:
  Erstdruck als »E. **Pleßner**« (Magazin für Litteratur), Erstausgabe als
  »Elsa **Pessner**: Warten. In: Der **G**läserne Käfig … **Wien**: Leopold
  Weiss 1901« – anderswo (L03695, K6) »Der gläserne Käfig … **Wien, Leipzig**:
  Leopold Weiss 1901«. Prüfen, ob die Namensform »Pessner« dem Titelblatt von
  1901 entspricht (vgl. auch die Unterschrift »Elsa Pessner« in L03698) –
  falls nein, vereinheitlichen; Groß-/Kleinschreibung und Verlagsort
  angleichen.
- **L03702, K13 (Kommentar)**: »handelte es sich um ein Korrespondenzstück
  Schnitzlers, **ein Brief** der Schriftstellerin Maria Janitschek und ein
  Konvolut« – Akkusativ: »einen Brief«. Verifiziert.
- **L03690, K1 (Kommentar)**: »**Von 23. 6. 1929 weg** fand die 7. Tagung des
  PEN-Klubs statt« – umgangssprachlich-österreichisch; standardnäher: »Ab dem
  23. 6. 1929« oder »Vom 23. 6. 1929 an«.
- **L03691, K1/K2 (Kommentar)**: »Julio **Alvares** del Vayo« (zweimal, auch im
  PMB-Personendatensatz) – der spanische Politiker/Schriftsteller schreibt
  sich »Julio Álvarez del Vayo«. Ebenda die bibl-Angabe »Fouché. Retrato
  **di** un Político« (auch als PMB-Werktitel) – spanisch wäre »de«; »di« ist
  italienisch. Publizierten Titel prüfen; ggf. auch in der PMB korrigieren.
- **L03695, K5 (Kommentar)**: »Wie die Celsius-Skala setzt die Réaumur-Skala
  den Nullwert beim **Taupunkt** von Wasser« – sachlich falsch: 0° liegt bei
  beiden Skalen am **Gefrierpunkt** des Wassers; der Taupunkt ist etwas
  anderes. Verifiziert.
- **L03698 (Brieftext)**: Unterschrift »Elsa **Pessner**« – ohne l; entweder
  ihr eigener Schreibfehler (dann Anmerkung erwägen) oder Transkriptions-
  versehen für »Plessner«. Prüffall Faksimile.
- **L03699, K2 (Kommentar)**: »die lyrische Zusammenstellung … ist ebenso
  verschollen wie die Novelle, als deren Teil sie geschrieben **wurden**« –
  Subjekt ist die (singularische) Zusammenstellung: »geschrieben wurde«
  (oder »als deren Teil die Gedichte geschrieben wurden«). Verifiziert.
- **L03680, K1 (Kommentar)**: »zusammen mit weiteren Gratulationsschreiben
  **zu 60. Geburtstag**« – richtig »zum 60. Geburtstag«. Verifiziert.
- **L03681, K2 (Kommentar)**: »Schapsel: (intellektuelles) Leichtgewicht,
  **Einfallspinsel**« – das Wort lautet »Einfaltspinsel« (zu »Einfalt«).
  Verifiziert.
- **L03683 (Brieftext, Maschinschrift)**: Anrede »Sehr verehrter lieber Herr
  **Doktor1**« – die Ziffer 1 wohl Tippfehler Zweigs an der Maschine (für
  »!« oder »,«); ohne Anmerkung wirkt sie wie ein Transkriptionsrest.
  textConst-Anmerkung erwägen. Ebenso im Postskript »gebe dann **meinern**
  Fingern Rast« ohne Anmerkung (das »Doktir« derselben Datei ist dagegen
  kommentiert).
- **L03688 (Brieftext, Maschinschrift, rn→m-Klasse)**: »in diesen kleinen
  **Ländem**« (Ländern), »unsere ganze Korrespondenz **übemimmt**«
  (übernimmt) – typische rn→m-Verlesung maschinschriftlicher Vorlagen
  (Transkribus); dazu »den ganzen **Nachrdrucks**- und Uebersetzungsbetrieb«
  (Nachdrucks-, mit überschüssigem r). Alle drei ohne textConst-Anmerkung.
  Prüffall Faksimile. (Korpusweite Suche nach weiteren rn→m-Kandidaten
  blieb sonst ohne Befund.)
- **L03688, K1 + L03741, K1 (Kommentar)**: Doppeltes »In:« in der (in beiden
  Dateien identisch kopierten) Asadowski-bibl – nach »In: Ders.:
  Russisch-deutsche Verflechtungen …« folgt noch einmal »**In:**
  Schriftenreihe des Instituts …, Band 24« – die Reihe ist kein
  Aufsatzcontainer; üblich wäre »(= Schriftenreihe …, Band 24)«.
- **L03689 (Brieftext, Maschinschrift)**: »Und erlauben Sie mir, **das**,
  wenn ich nächstens nach Wien komme, **ich** Ihnen noch glückwünschend die
  Hand reiche« – »das« statt »dass« und auffällige Wortstellung; keine
  textConst-Anmerkung. Prüffall Faksimile.
- **L03670 (Brieftext)**: Schlussformel »**Freulichst**, dankbarst Ihr« – wohl
  »Freundlichst« (oder Zweigs Versehen); keine textConst-Anmerkung. Ebenso
  »eine Gegengabe zu den **Iden den März**« – wohl »Iden des März«. Beides
  Prüffall Faksimile.
- **L03673 (Brieftext)**: »doppelt **anpruchsvoll** wider mich sein muss« –
  wohl »anspruchsvoll«; keine textConst-Anmerkung. Prüffall Faksimile.
- **L03673, K2 (Kommentar)**: »Spinoza verwendete den Begriff **um, in
  Analogie zur Geometrie,** den Zusammenhang … zu benennen« – Komma falsch
  gesetzt: richtig »verwendete den Begriff, um in Analogie zur Geometrie den
  Zusammenhang … zu benennen«. Verifiziert.
- **L03674 (Brieftext)**: »wenn ein **amer** Teufel von Leutnant« – wohl
  »armer« (r-Ausfall-Klasse); keine textConst-Anmerkung. Prüffall Faksimile.
- **L03678, K4 (Kommentar)**: »Das **Koncert** fand am 19. 9. 1919 … statt« –
  im Kommentar moderne Schreibung »Konzert« (das »Concert« des Brieftexts ist
  in die Anmerkung durchgerutscht). Verifiziert.
- **L03678, K3 (Kommentar)**: »um nicht **durch ihren Ehemann ein bestimmtes
  Bild in der Öffentlichkeit zu erwecken**« – verunglückte Formulierung;
  gemeint wohl »um in der Öffentlichkeit nicht über ihren Ehemann
  wahrgenommen zu werden« o. Ä. Umformulieren.
- **L03661 (Brieftext)**: »das mein **enziger** Trost … war« – wohl »einziger«
  (gleiche Fehlerklasse wie »enziffern« L02917); keine textConst-Anmerkung.
  Prüffall Faksimile.
- **L03662 (Brieftext)**: »die ganze künstlerische Plastik seiner
  **Pychologie**« – wohl »Psychologie«; keine textConst-Anmerkung. Prüffall
  Faksimile (folgt direkt auf einen Seitenumbruch).
- **L03669 (Brieftext)**: »die ein Rotschild kaum **seinem Brüder** a fond
  perdu lieh« – wohl »seinem Bruder«; keine textConst-Anmerkung. Prüffall
  Faksimile.
- **L03653 (Brieftext)**: »inwieweit Dr R. **im seiner** Offenheit des Wortes«
  – wohl »in seiner«; keine textConst-Anmerkung. Prüffall Faksimile.
- **L03653, K2 (Kommentar)**: »mit dem seit 1912 mit der Leitung **betreuten**
  Hugo Thimig« – richtig »betrauten«. Verifiziert.
- **L03655 (Brieftext)**: »gedenke noch **inngst** jenes andern« – wohl
  »innigst«; keine textConst-Anmerkung. Prüffall Faksimile.
- **L03656, K2 (Kommentar)**: »**Ein Tag** vor Reisebeginn nannte er…« –
  Akkusativ: »Einen Tag vor Reisebeginn«. Verifiziert.
- **L03658, K2 (Kommentar)**: »Am … **sang Olga ein Wohltätigkeitskonzert**« –
  schief: man singt kein Konzert (»gab … ein Wohltätigkeitskonzert« oder »sang
  bei einem…«); zudem nur Vorname »Olga« ohne Nachnamen, sonst meist »Olga
  Schnitzler«.
- **L03649, K1 (Kommentar)**: »Der **dies bezügliche** Textteil« –
  zusammenzuschreiben: »diesbezügliche«. Verifiziert.
- **L03649, K3 (Kommentar)**: »war der Montag **innnerhalb** der … Tage« –
  dreifaches n, richtig »innerhalb«. Verifiziert.
- **L03628, K2 (Kommentar)**: »was **zur Protestschreiben** und einem Skandal
  geführt hatte« – Kasusfehler: »zu Protestschreiben« bzw. »zu einem
  Protestschreiben«. Im selben Satz zuvor: »Schnitzler hatte es 1899 am
  Burgtheater eingereicht, **war dort abgelehnt worden**« – grammatisches
  Subjekt der Ellipse ist Schnitzler, gemeint ist das Stück (»es war dort
  abgelehnt worden«). Verifizierter Kommentarfehler.
- **L03630, K2 (Kommentar)**: »bekam am **17. 1.1912** die formelle Erlaubnis« –
  fehlendes Leerzeichen, Editionskonvention wäre »17. 1. 1912«. Verifiziert.
- **L03630, K2 (Kommentar)**: zitierter handschriftlicher Titel »Le Pays
  **Lontain**« (frz. korrekt wäre »Lointain«) – steht so auch als
  werk_namensvariante im Header. Falls getreue Wiedergabe der Handschrift:
  ggf. »[sic]« erwägen; sonst Transkriptionsfehler. Prüffall.
- **L03636, K3 (Kommentar)**: Im französischen Zitat aus dem Morisse-Brief
  »m’a dit vous **avois** parlé de moi« – korrektes Französisch wäre »avoir«;
  ob Morisse das wirklich so schrieb, gegen das Original prüfen. In der
  editorischen Übersetzung dazu zwei verifizierte Fehler: »mein Name ist
  **ihnen** nicht vollständig unbekannt« (Anredepronomen groß: »Ihnen«) und
  »er hätte **vor Ihnen von mir** gesprochen« – Gallizismus, idiomatisch:
  »er hätte mit Ihnen über mich gesprochen«.
- **L03587**: »Ganz besonders aber muß ich Ihnen für Ihr sozusagen öffentlich
  geäussertes Wort **sein**« – es fehlt »dankbar« (»muß ich Ihnen … dankbar
  sein«). Entweder Saltens Auslassung (dann Anmerkung erwägen) oder
  Transkriptionslücke. Prüffall Faksimile.
- **L03472**: »bitte ich nur noch um die **Erlaubis**« – wohl »Erlaubnis«
  (n fehlt), ohne Anmerkung. Prüffall Faksimile (evtl. Goldmanns Flüchtigkeit).
- **L03473**: »für die Überſendung **der** Exemplars« – »des Exemplars« oder
  »der Exemplare«; ohne Anmerkung. Prüffall Faksimile.
- **L03389**: »das Glück gehabt hatte, … **nigends** mit ihm
  zuſammenzukommen« – wohl »nirgends« (r fehlt), ohne Anmerkung. Prüffall
  Faksimile (gleiche r-Ausfall-Klasse wie vowärts/ergeifend/igend).
- **L03377** (K6): »**Arhtur** Schnitzler und Olga Gussmann heirateten am
  26. 8. 1903« – Buchstabendreher, → »Arthur«. **Verifizierter Fehler.**
- **L03375** (K3): »Am 2. 9. 1903 zogen Olga und Heinrich in eine Wohnung …
  **Zehn Tage später, am 2. 9. 1903**, zog Schnitzler ein« – zweimal dasselbe
  Datum (beide refs `1903-09-02`), obwohl »Zehn Tage später«; laut L03343 (K3)
  zog Schnitzler am 9. 9. 1903 ein (dann wäre auch »zehn Tage« ungenau, eher
  »eine Woche«). **Verifizierter Fehler** (innerer Widerspruch).
- **L03367** (K1): »waren – womöglich in Folge dieser Verabredung – am
  **28. 2. 1902** bei Elisabeth Gussmann« – der Brief stammt vom 28. 2. 1903;
  der Tagebuch-Ref hat `target="1902-02-28"` statt `1903-02-28`. Zifferndreher
  im Jahr. **Verifizierter Fehler.**
- **L03307** (K1) vs. **L02920** (K2): Die Alpenwanderung vom August 1900
  beginnt laut L02920 »am 16. 8. 1900 in Innsbruck«, laut L03307 startete sie
  »am 17. 8. 1900 … in Schruns (Vorarlberg)«. Ort und Datum des Beginns
  vereinheitlichen. Prüffall (Kommentar-Inkonsequenz).
- **L03267**: Der Brief ist editorisch auf den 1. [6.] 1897 datiert (Titel),
  die Datumszeile hat aber `<date when="1897-07-01">1. Juli 97</date>` – das
  `when`-Attribut folgt Saltens (laut Titel irriger) Monatsangabe statt der
  editorischen Datierung (→ `when="1897-06-01"`); zudem fehlt eine Anmerkung
  zur falschen Monatsangabe. **Verifizierter Fehler** (Attribut/Titel-Widerspruch).
- **L03205**: »die Veröffentlichung dieſer Antwort, die eine **ſchlicht**
  literariſchen Anſtandes iſt« – syntaktisch fehlt ein Substantiv; sehr
  wahrscheinlich Verlesung von »**Pflicht**« (Kurrent Pf/ſch), also »die eine
  Pflicht literariſchen Anſtandes iſt«. Prüffall Faksimile.
- **L03175**: »Schon deshalb weil er nicht **exisitirt**« – wohl »existirt«
  (Buchstabendreher wie beim Kommentar-Tippfehler »exisitieren« in L03039);
  Brieftext Saltens ohne Anmerkung. Prüffall Faksimile.
- **L03123**: »und **genzenlos** nervös« – wohl »grenzenlos« (r fehlt); im
  selben Brief auch »von den **gemeinschaftlichten** Soupers« (wohl
  »gemeinschaftlichen«). Beides ohne Anmerkung; Saltens Flüchtigkeit möglich.
  Prüffälle Faksimile.
- **L03095**: »unter **igend** einem Vorwande« – wohl »irgend« (r fehlt), ohne
  Anmerkung. Prüffall Faksimile.
- ~~L03095 (K2): sechsstellige Ziel-ID L041651~~ – **kein Fehler**: Die
  sechsstelligen IDs (L0414xx–L0416xx, korpusweit 15 Vorkommen in 13 Dateien)
  gehören zur Schnitzler/Bahr-Edition, dort existieren die Zieldateien
  (z. B. L041651.html). Refs mit `type="schnitzler-bahr"` sind korrekt.
  Auffällig allein: In L03678 (K4, K5) steht `subtype="Cf"` mit großem C
  statt des sonst üblichen `subtype="cf"` – prüfen, ob das die Verarbeitung
  stört.
- **L03066**: »**Schſade**, ſchade!« – auffällige Buchstabenfolge (Sch+ſ);
  entweder Goldmanns Schreibfehler (dann Anmerkung erwägen) oder
  Transkriptionsversehen für »Schade, ſchade!«. Prüffall Faksimile.
- **L02960** (K1): »da er weder eine **Andrede** noch eine Unterschrift
  aufweist« – Tippfehler, → »Anrede«. **Verifizierter Fehler.**
- **L02917**: »habe ich nicht **enziffern** können« – wohl »entziffern«
  (t fehlt), ohne Anmerkung; Goldmanns Schreibfehler möglich. Prüffall Faksimile.
- **L02890**: »Herzlichſten **Dark** für Deine Telegramme« – wohl »Dank«
  (nk/rk-Verlesung), ohne Anmerkung. Prüffall Faksimile.
- **L02883** (K1): Zur Karte vom 8. 8. 1899 heißt es »Schnitzler hielt sich in
  Italien auf« – laut L02877 (K2) stand Italien aber am *Ende* der Sommerreise
  (Rückkehr nach Wien 12. 10. 1899), und schon am 20. 8. 1899 (L02884) ist die
  Karte nach Bad Ischl adressiert. Ob er Anfang August wirklich in Italien war,
  gegen das Tagebuch prüfen. Prüffall.

<!-- FORTSCHRITT: KORPUS VOLLSTÄNDIG GELESEN (bis L04528; alle vorhandenen editions/L*.xml) -->

---

*Dieses Protokoll wird fortgeschrieben. Abschnitte 1–3 beruhen auf dem maschinellen
Volldurchlauf über alle 4366 Dateien und sind vollständig; Abschnitt 4 wächst mit dem
Lektürefortschritt.*
