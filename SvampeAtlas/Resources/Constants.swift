//
//  Constants.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 26/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import Foundation

let BASE_URL = "https://svampe.databasen.org/api/taxa?_order=%5B%5B%22FullName%22%5D%5D&acceptedTaxaOnly=true&include=%5B%7B%22model%22:%22TaxonRedListData%22,%22as%22:%22redlistdata%22,%22required%22:false,%22attributes%22:%5B%22status%22%5D,%22where%22:%22%7B%5C%22year%5C%22:2009%7D%22%7D,%7B%22model%22:%22Taxon%22,%22as%22:%22acceptedTaxon%22%7D,%7B%22model%22:%22TaxonAttributes%22,%22as%22:%22attributes%22,%22attributes%22:%5B%22PresentInDK%22%5D,%22where%22:%22%7B%5C%22PresentInDK%5C%22:true%7D%22%7D,%7B%22model%22:%22TaxonDKnames%22,%22as%22:%22Vernacularname_DK%22,%22required%22:false%7D,%7B%22model%22:%22TaxonStatistics%22,%22as%22:%22Statistics%22,%22required%22:false%7D,%7B%22model%22:%22TaxonImages%22,%22as%22:%22Images%22,%22required%22:true%7D%5D&limit=100&offset=0&where=%7B%7D"
