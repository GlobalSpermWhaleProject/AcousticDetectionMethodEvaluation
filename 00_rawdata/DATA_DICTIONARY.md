# Data Dictionary

**Project Name**: Evaluation of Methods of Sperm Whale Acoustic Detection

**Date created**: March 3, 2026

**Created by**: Christine Clarke

## Summary

This document describes all variables contained in the raw data files within the `00_rawdata` directory.

## Shared Screening Details

### Screening Outcome Codes

- Y: Passed screening / Included
- N: Did not pass screening / Excluded
- NA: Not applicable (excluded at earlier stage or not available for assessment)

## 01_Results_WoS-search.csv

Web of Science (WoS) export with standard bibliographic fields plus custom screening columns.

### Bibliographic Fields (As exported from Web of Science)

- Relevance_Rank_WoS: Relevance ranking assigned by Web of Science
- Publication Type: Type of publication (J = Journal, C = Conference)
- Authors: Author names (abbreviated format)
- Book Authors: Book author names (if applicable)
- Book Editors: Book editor names (if applicable)
- Book Group Authors: Book group author names (if applicable)
- Author Full Names: Complete author names
- Book Author Full Names: Complete book author names (if applicable)
- Group Authors: Group author names (if applicable)
- Article Title: Title of the publication
- Source Title: Journal or conference name
- Book Series Title: Book series title (if applicable)
- Book Series Subtitle: Book series subtitle (if applicable)
- Language: Publication language
- Document Type: Article, Review, Proceedings Paper, etc.
- Conference Title: Name of conference (if applicable)
- Conference Date: Date of conference (if applicable)
- Conference Location: Location of conference (if applicable)
- Conference Sponsor: Conference sponsor (if applicable)
- Conference Host: Conference host (if applicable)
- Author Keywords: Keywords provided by authors
- Keywords Plus: Additional keywords from Web of Science
- Abstract: Publication abstract
- Addresses: Author institutional addresses
- Affiliations: Author affiliations
- Reprint Addresses: Corresponding author address
- Email Addresses: Corresponding author email
- Researcher Ids: Researcher ID numbers
- ORCIDs: ORCID identifiers
- Funding Orgs: Funding organizations
- Funding Name Preferred: Preferred funding name
- Funding Text: Funding acknowledgement text
- Cited References: References cited in the publication
- Cited Reference Count: Number of cited references
- Times Cited, WoS Core: Citation count in WoS Core Collection
- Times Cited, All Databases: Total citation count across all databases
- 180 Day Usage Count: Usage count in last 180 days
- Since 2013 Usage Count: Usage count since 2013
- Publisher: Publisher name
- Publisher City: Publisher city
- Publisher Address: Publisher address
- ISSN: International Standard Serial Number
- eISSN: Electronic ISSN
- ISBN: International Standard Book Number
- Journal Abbreviation: Abbreviated journal title
- Journal ISO Abbreviation: ISO abbreviated journal title
- Publication Date: Date of publication
- Publication Year: Year of publication
- Volume: Journal volume
- Issue: Journal issue
- Part Number: Part number (if applicable)
- Supplement: Supplement information
- Special Issue: Special issue designation
- Meeting Abstract: Meeting abstract indicator
- Start Page: First page number
- End Page: Last page number
- Article Number: Article number
- DOI: Digital Object Identifier
- DOI Link: URL link to DOI
- Book DOI: Book DOI (if applicable)
- Early Access Date: Early access date
- Number of Pages: Total page count
- WoS Categories: Web of Science subject categories
- Web of Science Index: WoS index information
- Research Areas: Research area classifications
- IDS Number: IDS number
- Pubmed Id: PubMed identifier
- Open Access Designations: Open access status
- Highly Cited Status: Highly cited paper indicator
- Hot Paper Status: Hot paper indicator
- Date of Export: Date data was exported from WoS
- UT (Unique WOS ID): Unique Web of Science identifier
- Web of Science Record: WoS record indicator

### Custom Screening Fields

- Screening_by-title: Outcome of title screening (Y, N, NA; as described above)
- Screening_by-year: Outcome of year filter >2010 (Y, N, NA; as described above)
- Screening_by-abstract: Outcome of abstract screening (Y, N, NA; as described above)
- Screening_by-fulltext: Outcome of full-text screening (Y, N, NA; as described above)
- Comments: Reviewer notes (free text)

## 01_Results_Gracic-et-al-2025-references.csv

References extracted from Tables 1-3 in the Gracic et al. (2025) review paper for potential inclusion.

Gracic, Mak, Guy Gubnitsky, and Roee Diamant. 2025. “A Survey of Detection Techniques for Sperm Whale and Dolphin Echolocation Clicks.” Frontiers in Marine Science 12 (October). https://doi.org/10.3389/fmars.2025.1567001.

- RefShortHand: Short citation format (Author et al., Year)
- Source: Location in the source paper ("Table 1", "Table 2", "Table 3")
- OrderInPaper: Sequential order as listed in paper
- PrefilterRejectStage: Stage at which reference was pre-filtered out
    - Duplicate check: Reference already captured in WoS search
    - Year: Publication year ≤2010
    - Main idea: 'Main Idea' column in Gracic et al. (2025) table suggested not focused on sperm whale detection
    - Cons: Based on 'Con' column in Gracic et al. (2025) table. E.g., high computational requirements
    - NA: Not pre-filtered; proceeded to screening
- PrefilterRejectDetails: Reason for pre-filter rejection (text description)
- Screening_by-title: Outcome of title screening (Y, N, NA; as described above)
- Screening_by-abstract: Outcome of abstract screening (Y, N, NA; as described above)
- Screening_by-fulltext: Outcome of full-text screening (Y, N, NA; as described above)

## 01_Results_Other.csv

Additional references identified outside the Web of Science search or Gracic et al. (2025) review paper. Methods were only added to this list if they were already identified as passing full text relevance screening.

- RefShortHand: Short citation format (Author et al., Year)
- Full reference: Complete bibliographic reference
- Source: How the reference was identified
    - WoS Document Reference: method used or referenced in WoS result
    - Google Scholar Alert
    - Expert opinion
- Screening_by-fulltext: Outcome of full-text screening (Y, N, NA; as described above)

## 02_FilteredResults_SecondaryScreening.csv

Combined results of all three '01' files, keeping only results that passed initial filtering (i.e., Screening_by-fulltext == "Y"). 

- Relevance_Rank_WoS: Relevance ranking from WoS (if applicable, integer)
- UT (Unique WOS ID): Unique Web of Science identifier; can be used as foriegn key to link data to 01_Results_WoS-search.csv
- Source: Source of the reference ("WoS", "Other", "Gracic et al. 2025"); incidates which '01' file has full bibliographic details
- RefShortHand: Short citation format; can be used as foriegn key to link data to 01_Results_Gracic-et-al-2025-references.csv or 01_Results_Other.csv
- MethodPlatform: Software platform used for detection (e.g., PAMGuard, Raven, CABLE)
- MethodType: Type of detection method (e.g., LTSA, Click detector)
- MethodReference: Reference for the method if previously published (matching RefShortHand column), or blank if the method is primarily described in the current reference
- SelectedForDetailedConsideration: Whether selected for detailed extraction (Y or N)
- Comments: Additional notes (free text), e.g., an explanation of why a method was not selected for detailed consideration

## 03_ShortList_StudyDetails.csv

Final shortlist of studies with detailed methodological information extracted.

- RefShortHand: Short citation format; can be used as foriegn key to link data to 02_FilteredResults_SecondaryScreening.csv
- SamplingRate_kHz: Audio sampling rate in kilohertz (numeric)
- RecordingSchedule: Recording duty cycle or schedule (e.g., "continuous", "duty cycle (10/60m)")
- DetectorPlatform: Software platform for detection
- Preprocessing: Audio preprocessing steps applied (text description, e.g., high pass filter details)
- DetectionMethod: General detection approach (e.g., LTSA, Click detector)
- DetectorDetails: Specific detector parameters/settings (text description)
- ClassifierType: Type of classifier used, if any (short text description)
- ClassifierDetails: Specific classifier parameters/settings (longer text description)
- PerformanceDetails: Reported performance metrics (e.g., precision, recall values)
- ManualReview: Manual review required for method (text description)
- Comments: Additional notes (free text)
