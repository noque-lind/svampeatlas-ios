//
//  AboutVC.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 13/09/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: UIBarButtonItem.Style.plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu))
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.appConfiguration(translucent: false)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        title = "Om"
        view.backgroundColor = UIColor.appSecondaryColour()
        
         navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: .plain, target: eLRevealViewController(), action: #selector(eLRevealViewController()?.toggleSideMenu)), animated: false)
        
        let contentStackView: UIStackView = {
            func createImageViewWithImage(image: UIImage) -> UIImageView {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                return imageView
            }
            
            func createText(title: String, message: String) -> UIStackView {
                let header: SectionHeaderView = {
                    let view = SectionHeaderView()
                    view.configure(text: title)
                    return view
                }()
                
                let messageLabelStackView: UIStackView = {
                   let stackView = UIStackView()
                    stackView.isLayoutMarginsRelativeArrangement = true
                    stackView.layoutMargins = UIEdgeInsets(top: 0.0, left: 8, bottom: 0.0, right: 8)
                    let messageLabel: UILabel = {
                        let view = UILabel()
                        view.font = UIFont.appPrimary()
                        view.textColor = UIColor.appWhite()
                        view.backgroundColor = UIColor.clear
                        view.numberOfLines = 0
                        view.text = message
                        return view
                        }()
                    
                    stackView.addArrangedSubview(messageLabel)
                    return stackView
                }()
                
                
               
                
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 4
                stackView.addArrangedSubview(header)
                stackView.addArrangedSubview(messageLabelStackView)
                return stackView
                }
        
    
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 32
            stackView.distribution = .fill
            stackView.alignment = .fill
            
            stackView.addArrangedSubview(createImageViewWithImage(image: #imageLiteral(resourceName: "Images_Sponsors_KU")))
            stackView.addArrangedSubview(createImageViewWithImage(image: #imageLiteral(resourceName: "Images_Sponsors_Aage V. Jensen")))
            stackView.addArrangedSubview(createImageViewWithImage(image: #imageLiteral(resourceName: "Images_Sponsors_Svampekundskabens fremme")))
            stackView.addArrangedSubview(createText(title: "Artsbestemmelse", message: """
Brug af automatisk billedegenkendelse kan aldrig være helt præcis, og det er derfor vigtigt at systemet bruges med endnu mere kritisk sans end din svampebog. Spis aldrig svampe uden at søge hjælp fra svampekyndige mennesker. Danmarks Svampeatlas og Noque ApS frasiger sig ethvert ansvar for eventuelle forgiftninger eller andre sundhedsskadelige forhold.

Billedegenkendelses systemet er udviklet af Milan Šulc og Professor Jiri Matas fra det Tjekkiske Tekniske Universitet (CTU) i Prag, Lukáš Picek fra University of West Bohemia (UWB) i Tjekkiet og Danmarks Svampeatlas.
"""))
            
            stackView.addArrangedSubview(createText(title: "Generelt", message: """
Svampeatlas 2.0 bygger videre på atlasprojektet Danmarks Svampeatlas, som kortlagde danske storsvampe, med hovedfokus på basidiesvampene i en femårig periode fra 2009-13. Projektet var støttet af Aage V. Jensen Naturfond og havde som hovedformål at øge vores viden om svampenes udbredelse og økologi i Danmark, og at gøre denne viden tilgængelig for offentligheden.

Mere end 400 frivillige var involveret i Danmarks Svampeatlas, hvor de bidrog med ca. 250.000 kvalitetstjekkede svampefund. Siden er yderligere ca. 50.000 nye svampefund kommet til, mens godt 230.000 gamle svampefund er importeret i projektdatabasen som nu indeholder mere end 600.000 kvalitetstjekkede svampefund. Projektet har medført et langt bedre kendskab til Danmarks funga. Mere end 180 basidiesvampe er blevet føjet til listen over kendte danske arter, og flere arter der var regnet som uddøde er genfundet. Samtidigt er der udviklet en række søge- og hjælpefunktioner der præsenterer vores viden om de enkelte svampearter i overskuelig form, og som gør det meget nemmere at inddrage viden om truede svampearter i naturforvaltningen.

I Svampeatlas 2.0 er det målet at fastholde, fremtidssikre og videreudvikle de ressourcer der er opbygget gennem Danmarks Svampeatlas, til glæde for alle naturinteresserede og til gavn for alle der arbejder med naturforvaltning professionelt. Dette vil bl.a. ske gennem udvikling af en ny databasestruktur, og et interaktivt brugerinterface, der i høj grad inddrager de frivillige svampekyndige som aktive medspillere i processen med at sikre høj datakvalitet. Samtidigt vil vi indbygge smarte filtre, baseret på eksisterende viden om svampenes fænologi og udbredelse i Danmark, der automatisk kan registrere om et nyt svampefund kan regnes som sandsynligt.

Udover udviklingen af nye database og web-funktioner vil projektet udvikle en mobil-app til bestemmelse og registrering af svampefund i felten. Derudover er det målet at fastholde projektets overordnede koncept og resultater i en sammenfattende bog om Danmarks Svampeatlas, samt at skrive et nyt bestemmelsesværk for Danmarks basidiesvampe, baseret på de bestemmelsesnøgler der blev lavet i Danmarks Svampeatlas.

Svampeatlas 2.0 udføres i et samarbejde mellem Center for Makroøkologi, Evolution og Klima (CMEC) ved Statens Naturhistoriske Museum (SNM), Københavns Universitet, Foreningen til Svampekundskabens Fremme og MycoKey. Projektgruppen består af Tobias Guldberg Frøslev, Thomas Stjernegaard Jeppesen, Thomas Læssøe (SNM) og Jens H. Petersen med Jacob Heilmann-Clausen som projektleder. Projektet er støttet af Aage V. Jensens Naturfond.
"""))
            
            stackView.addArrangedSubview(createText(title: "Generelle betingelser", message: """
Når du opretter dig som bruger/indrapportør på Danmarks Svampeatlas, har du mulighed for at indlægge svampefund og kommentere på andres fund. Nedenfor gennemgår vi mere detaljeret de betingelser og retningslinier, som vi arbejder efter.

Alle kan oprette sig som brugere på Danmarks Svampeatlas. Alle indrapporteringer og kommentarer er åbent tilgængelige for alle brugere. Vi henstiller til en god og konstruktiv omgangstone og gør opmærksom på, at du er ansvarlig for de handlinger, der bliver foretaget med dit login på netstedet. Ved gentagne brud på de specifikke retningslinjer som gennemgås nedenfor, forbeholder Danmarks Svampeatlas sig ret til at slette din profil og/eller stoppe din brugeradgang. Det samme kan ske i tilfælde af grov og gentagen forsømmelse af almindelige regler for god omgangstone på nettet.

Vi ser meget gerne at du uploader fotos og tekst som dokumentation for dine svampefund. I mange tilfælde kan et godt foto være et krav for, at dine fund kan valideres. Hvis du anvender fotos eller tekster, der ikke er dine egne, skal du sikre at du har rettigheder til at bruge disse. Du er desuden forpligtet til så vidt muligt at sikre, at de geografiske koordinater knyttet til hvert fund er præcise, og at det valgte zoom-niveau ikke resulterer i en højere præcision end der er belæg for.

Informationer og fotos, som du har videregivet til Danmarks Svampeatlas, vises på projektets hjemmeside, under det enkelte fund og ved gallerivisninger for de arter som fundene repræsenterer. Fotos og andre informationer er knyttet til det enkelte svampefund og udgør i mange tilfælde en vigtig dokumentation som derfor ikke slettes. Ved visning på Danmarks Svampeatlas vil fotografens navn tydeligt fremgå. Brug af billederne, ud over de nævnte, vil kun finde sted efter direkte aftale med brugerne, som beholder alle rettigheder til egne fotos. Sender du belæg som dokumentation for enkelte fund, vil den enkelte ekspert beslutte om belægget skal gemmes for eftertiden i samlingerne på Statens Naturhistoriske Museum ved Københavns Universitet eller ved en anden internationalt anerkendt samling.

De fund-data du indtaster i Danmarks Svampeatlas, videregives til den Globale Biodiversisetets Facilitet (GBIF) under OECD og er internationlt søgbare via gbif.org under OECD. Billeder som er uploadet som dokumentation af hvert fund er linket til dette og er således synlige hos GBIF. Ønsker du ikke at links til dine billeder videregives til GBIF, så send venligst en email til atlas@svampe.dk

Hvis du på et tidspunkt vælger at få slettet din profil, forbliver alle informationer og materiale indlagt med denne profil synlige og søgbare på projektets hjemmeside.

Validatorer og administratorer har ret til at slette/ændre information, som vedrører dine observationer, så længe retningslinjerne for information ikke bliver overtrådt derved.
"""))
            
            stackView.addArrangedSubview(createText(title: "Kvalitetssikring/validering", message: """
For at sikre at de informationer, der ligger i svampebasen er troværdige, undergår alle fund kvalitetssikring. Fund af arter uden valideringskrav bliver automatisk godkendt, mens fund af arter med valideringskrav som udgangspunkt er uvaliderede, indtil de er godkendt af en validator. For de valideringskrævende arter er der angivet en række valideringskrav. Hvis disse krav ikke er opfyldt i forbindelse med indlæggelse af fund, kan man ikke regne med en seriøs behandling af observationen og fundet afvises. Godkendte fund, også af arter, der ikke kræver validering, kan senere afvises af validatorer, fx hvis det vurderes at der ikke er tilstrækkelig dokumentation til at fundet kan godkendes eller at den vedlagte dokumentation viser, at det er en anden men ubestemmelig art. Alle brugere har mulighed for at kommentere på alle fund - både uvaliderede, godkendte og afviste. Kvalitetssikring/validering kræver ofte mikroskopisk undersøgelse af materiale, hvorfor behandlingstiden kan være lang.
"""))
            
            stackView.addArrangedSubview(createText(title: "Retningslinier for brug af data fra Danmarks Svampeatlas", message: """
Simple funddata kan søges via webinterfacet på Danmarks Svampeatlas og kan frit bruges i alle typer af forvaltningsopgaver på såvel lokalt som nationalt plan, fx i forbindelse med miljøvurderinger (VVM’er), udarbejdelse af plejeplaner samt til lokal og national prioritering af naturbeskyttelse i Danmark. Danmarks Svampeatlas bør i hvert tilfælde citeres som kilde. Data kan på tilsvarende vis bruges i forskningssammenhæng. Bemærk at databasen indeholder både godkendte, uvaliderede og afviste fund, hvilket er specificeret under hvert fund.

Valideringsprocessen omfatter artsbestemmelsen, og de grovere geografiske data. Især ældre fund har ofte meget upræcise fund-koordinater, men også for helt nye fund kan de være upræcist angivet. Den brugerdefinerede usikkerhed på fund-koordinater er angivet i meter for hvert fund, og skal betragtes som vejledende, fx ved udarbejdelse af detaljerede lokale forvaltningsplaner. Danmarks Svampeatlas rummer et meget stort antal standardnavne for lokaliteter, som vælges af rapportøren. Det betyder, at fund af den samme svamp kan være indrapporteret med flere forskellige lokalitetsnavne af forskellige brugere, og tillige med forskellige koordinater. I praksis er dette mest aktuelt for meget sjældne og karismatiske arter, fx pindsvinepigsvamp og safrangul fedtporesvamp.
"""))
            
            return stackView
        }()
        
        
        let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(contentStackView)
            scrollView.contentInset = UIEdgeInsets(top: 16, left: 0.0, bottom: 16, right: 0.0)
            
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            return scrollView
        }()
        
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}
