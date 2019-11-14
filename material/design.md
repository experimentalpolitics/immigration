# Media Usage and News Consumption: Study Design & Questionnaire

## Survey Flow Overview

- Pre-treatment measures:
    - Media usage
    - Stereotype battery
    - Political attitudes & participation
- Experimental manipulation:
    - Tweets
    - Full story
    - Attention checks & article evaluation
- Post-treatment measures:
    - Attitudes towards immigration
    - Trust in news sources
    - Sociodemographics

## Treatment Overview

- **Basic design:** 3-arm (choice/assigned + control)
    - _Treatment (choice/assigned):_ Participants are either asked to choose whether they would like to view a tweet by Fox News or MSNBC (_choice condition_), or they are randomly assigned to one of them (_assigned condition_). The Tweet links to a news story about the positive economic impact of legal immigration to the US. After viewing the tweet, participants are asked to read the full article. Irrespective of the source (Fox News or MSNBC), the content of the tweet is held constant. 
    - _Control condition:_ Skip tweet & full story

- **Outcome measures:**
    - Do participants try to click on the tweet?
    - How much time do participants spend viewing the tweet?
    - How much time do participants spend reading the full article?
    - Basic comprehension / attention check.
    - Attitudes towards article, sharing with others?
    - Attitudes towards immigration (see post-treatment section).
    - Trust in news sources (see post-treatment section).

## MTurk Details

- *Title:* Media Usage and News Consumption
- *Description:* Answer a short survey about your personal media diet and issues currently discussed in the news.
- *Length:* <30 min
- *Reward:* $2
- *Requirements:* 90% approval rate, location US

## Pre-treatment measures

### Block 1: Media usage

First, we want to ask a few questions about your current media diet.

**[smedia]** *(show same response options for each, randomize order)* On average, how often do you use the following social media platforms?

- YouTube
- Facebook
- Instagram
- Twitter
- Tumblr

1. Several times a day
2. About once a day
3. 3 to 6 days a week
4. 1 to 2 days a week
5. Every few weeks
6. Less often
7. Never
8. Don’t Know

**[tv]** *(show same response options for each, randomize order)* On average, how often do you watch _political_ news on the following TV channels (including online content)?

- Fox News
- MSNBC
- CNN
- NBC
- CBS

1. Several times a day
2. About once a day
3. 3 to 6 days a week
4. 1 to 2 days a week
5. Every few weeks
6. Less often
7. Never
8. Don’t Know

**[print]** *(show same response options for each, randomize order)* And how often do you read about articles about _politics_ in the following newspapers (online or offline)?

- New York Times
- Washington Post
- Wall Street Journal
- USA Today
- New York Post

1. Several times a day
2. About once a day
3. 3 to 6 days a week
4. 1 to 2 days a week
5. Every few weeks
6. Less often
7. Never
8. Don’t Know

### Block 2: Stereotype battery

Next are some questions about different groups in our society.

**[st_job]** *(show same response options for each, randomize order)* Do you think that people in the following groups tend to be "intelligent" or "unintelligent"?

- Farmers
- Teachers
- Lawyers
- Politicians

(1) Intelligent - (7) Unintelligent, (8) DK

**[st_race]** *(show same response options for each, randomize order)* And do you think that people in the following groups are "hard-working" or "lazy"?

- Whites
- Blacks
- Hispanic-Americans
- Asian-Americans

(1) Hard-working - (7) Lazy, (8) DK

**[st_age]** *(show same response options for each)* And do you think that people in the following groups are "generous" or "selfish"?

- Silent Generation (born 1945 and before)
- Baby Boomers (born 1946-1964)
- Generation X (born 1965-1976)
- Millennials (born 1977-1995)

(1) Generous - (7) Selfish, (8) DK

### Block 3: Political attitudes & participation

Next, we would like you to answer a few questions about your political viewpoints.

**[polint]** How often do you pay attention to what's going on in government and politics?

1. Always
2. Most of the time
3. Sometimes
4. Hardly at all
5. Never

**[problem]** *(randomize order)* What do you think are the most important problems facing this country? Please rank the following issues from the most important to the least important.

1. Economy
2. Terrorism
3. Immigration
4. Health Care
5. Environment

**[ideol]** Thinking about politics these days, how would you describe your own political viewpoint?

1. Very liberal
2. Liberal
3. Slightly liberal
4. Moderate
5. Slightly conservative
6. Conservative
7. Very conservative
8. Not sure

**[pid]** Generally speaking, do you think of yourself as a Republican, a Democrat, an independent, or other?

1. Republican
2. Democrat
3. Independent
4. Other

**[pid_lean]** *(if [pid] == other | independent)*
Do you think of yourself as CLOSER to the Republican party or to the Democratic party?

1. Republican party
2. Democratic party
3. Neither party

**[pid_rep/pid_dem]** *(if [pid] == Republican | Democrat)*
Would you consider yourself a strong Republican/Democrat or a not very strong Republican/Democrat?

1. Strong
2. Not very strong

<!-- \newpage -->

## Experimental manipulation

### Instructions for participants

- **If treatment condition = choice**
    - In the following section, we are going to show you a random tweet drawn from the accounts of two large news organizations. You can choose from which Twitter account the random tweet will be drawn. Afterwards, we are going to ask you some questions about the content of the news story.
    - **[choice]** _(randomize order)_ From which Twitter account would you like to view a random tweet?
        
        1. Fox News
        2. MSNBC

- **If treatment condition = assigned**
    - In the following section, we are going to show you a random tweet drawn from the accounts of several large news organizations. Afterwards, we are going to ask you some questions about the content of the news story.
    - **[assigned]** _(assignment to account invisible to participant)_
        
        1. Fox News
        2. MSNBC

### Tweets

![Fox News](tweets/fox_popular.png){width=50%}

![MSNBC](tweets/msnbc_popular.png){width=50%}

### Introduction for full story

Next, we will show you the content of the article linked in the previous tweet. **Please read the story carefully.** Keep in mind that we will ask you questions about the content of the article afterwards.

_There will be a brief pause on the next screen so you can read the story._ At the end of the pause, an arrow will appear at the bottom of the screen. Once the arrow appears, you may move on to the next screen of the survey by clicking on the arrow.

### Full Story: Immigrant-owned Businesses on the Rise

William Hall | [Fox News/MSNBC]

A recent report released using U.S. Census Bureau data states that immigrant-owned businesses employed over 8 million workers in fiscal year 2017, up from 2016 totals. These businesses also experienced an increase in the total amount of sales revenue, which rose to almost $1.3 trillion during the same period.

These statistics are borne out of hundreds of success stories across many different sectors of the economy, especially the service industry.

![Percent of Immigrant Entrepreneurs](fig/immig_entrepreneurs.png){width=45%}

Eduardo Rodriguez, a 62 year old immigrant living in the Little Village neighborhood of Chicago, is a perfect example of this success. In an area of the city that has an unemployment rate of 13 percent and an annual median income of $30,000--less than half of the national average--the Little Village community faces considerable economic challenges. However, these conditions have not stopped Rodriguez.  He currently owns and operates four Dulcelandia stores in Little Village, each one packed with over 1,000 types of delicious candies from his home country of Mexico.

After immigrating here in 1966, Rodriguez opened his first store and it became an instant gathering spot in the neighborhood. "People seem to really like what we are doing, and I'm grateful that I had the opportunity to do this in the United States. It takes a lot of work and sacrifice -- we're fulfilling a niche market that people really want to buy from."

Following in her father's footsteps, Rodriguez's daughter, Eve Rodriguez Montoya, has also opened up a handful of shops that specialize in healthy frozen yogurts with some Mexican-inspired flavors.

"Our community is very strong and hard-working -- resilient and resourceful," she said. "I'd say come to our community, get to know our people. Shop at our locations and see for yourself -- Little Village is full of people who came to this country to achieve the American Dream."

The Rodriguez's story is just one of many. As more immigrants look to open their own businesses and employ more workers, many markets, both broad and niche, will continue to expand and provide more fuel to an already strong economy.

*William Hall is a Business Reporter for [Fox News/MSNBC].*

### Attention checks & article evaluation

Please answer the following questions about the tweet as well as the article you just read.

**[source]** *(randomize order)*  Which Twitter account / news organization published the story?

1. Fox News
2. MSNBC
3. New York Times
4. Wall Street Journal
5. Other
6. Don't know

**[about]** *(randomize order)* Broadly speaking, what was the news story about?

1. Immigrant-owned businesses
2. Stock market development
3. Innovation in the automotive industry
4. Young entrepreneurs in Silicon Valley
5. Don't know

**[actions]** Thinking about the news article you just read, how likely would you be to:

- Discuss the story with a friend
- Forward the story to a friend or colleague via email
- Post a link to the story on a social networking site, such as Facebook or Twitter
- Seek out additional information from another source on the topic featured in the story

(1) Very likely - (4) Not likely, (7) Not sure

**[wordpairs]** *(randomize order)* Below, you will find a list of pairs of words. Please rate the news article you just read on each of the pairs of words.

- [fair] (1) Fair - (5) Unfair
- [hostile] (1) Hostile - (5) Friendly
- [bad] (1) Bad - (5) Good
- [skewed] (1) Skewed - (5) balanced
- [american] (1) American - (5) Un-American
- [accurate] (1) Accurate - (5) Inaccurate

### Sources for story

- Immigrant story: [link](https://www.cnbc.com/2017/05/02/how-successful-immigrant-entrepreneurs-are-changing-chicago-and-the-us.html)
- Graph: [link](https://www.inc.com/arnobio-morelix/inc-entrepreneurship-index-2018-q1.html)
- Immigrant Statistics: [link](https://www.newamericaneconomy.org/methodology/)
    <!-- - This data is aggregated by a group called The New American Economy; it gathers the data from the US Census, many different local OMBs, the  National Bureau of Economic Research, and others. Not 100% sure we can say this was 'released' by the US Census bureau. -->

<!-- \newpage -->

## Post-treatment measures

### Block 1: Attitudes towards immigration

_(only show this message in the control condition)_ In this section, we want to ask you a few questions about immigration.

**[employ]** Across the United States, how many workers -- immigrant and US-born -- do you think are employed by immigrant-owned businesses?

1. Less than 500,000
2. 500,000 - 1 million
3. 1 million - 5 million
4. 5 million - 10 million
5. More than 10 million

**[sales]** Taking your best guess, what was the total amount of sales revenue of immigrant-owned businesses in the last year?

1. Less than $500 billion
2. $500 billion - $1 trillion
3. $1 trillion - $1.5 trillion
4. $1.5 trillion - $2 trillion
5. More than $2 trillion

_(only show this message in the treatment conditions)_ In this section, we want to ask you a few questions about immigration in general.

**[immig]** Do you think the number of immigrants from foreign countries who are permitted to come to the United States to live should be...?

1. Increased a lot
2. Increased a little
3. Left the same
4. Decreased a little
5. Decreased a lot

_(randomize order of remaining questions)_

**[taxes]** Most people who come to live in the U.S. work and pay taxes.  They also use health and social services.  On balance, do you think people who come here take out more than they put in or put in more than they take out?

- 0 (Generally take out more) - 10 (Generally put in more)

**[taxes_oe]** Please explain your answer to the previous question in a few short sentences.

- *TEXTBOX*

**[jobs]** On average, would you say that people who come to live here from other countries will take jobs away from people already here or add to the economy by creating additional jobs?

- 0 (Take jobs away) - 10 (Create additional jobs)

**[jobs_oe]** Please explain your answer to the previous question in a few short sentences.

- *TEXTBOX*

### Block 2: Trust in news sources

Let's briefly return to the different media sources mentioned at the beginning of the survey.

**[tv_trust]** *(show same response options for each, randomize order)* Overall, how often can you trust the following TV channels that their political news reporting is accurate?

- Fox News
- MSNBC
- CNN
- NBC
- CBS

1. Always
2. Most of the time
3. About half the time
4. Sometimes
5. Never
6. Don’t Know

**[print_trust]** *(show same response options for each, randomize order)* And how often can you trust the following newspapers that their political reporting is accurate?

- New York Times
- Washington Post
- Wall Street Journal
- USA Today
- New York Post

1. Always
2. Most of the time
3. About half the time
4. Sometimes
5. Never
6. Don’t Know

### Block 3: Sociodemographics

This almost completes our survey, we only need some additional information about your background.

**[age]** What is your age?

- *TEXTBOX*

**[gender]** Do you consider yourself Male, Female, or other?

1. Male
2. Female
3. Other

**[usborn]** Were you born in the United States?

1. Yes
2. No

**[usborn_year]** *(only ask if [usborn]==0)* When did you first arrive to live in the US?

- *TEXTBOX*

**[zip]** What is your zip code?

- *TEXTBOX* *(response not required)*

**[zip_time]** *(only ask if zip code is entered)* And how long have you lived at your current zip code?

1. Less than a year
2. 1 to 3 years
3. 3 to 5 years
4. More than 5 years
5. Don't Know

**[race]** What racial or ethnic group best describes you?

1. Asian/Pacific Islanders
2. Black or African-American (non-Hispanic)
3. Caucasian/White (non-Hispanic)
4. Hispanic or Latino
5. Middle eastern
6. Native American or Aleut
7. Other

**[educ]** What is the highest level of education that you have completed?

1. Less than a high school diploma
2. Graduated high school or GED
3. Some college but no college degree
4. Graduated 2-year college
5. Graduated 4-year college
6. Completed post-graduate or professional school, with degree
7. Don't know

**[income]** Thinking back over the last year, what was your family's annual income?

1. Less than $20,000
2. $20,000 - $39,999
3. $40,000 - $59,999
4. $60,000 - $79,999
5. $80,000 - $99,999
6. $100,000 - $119,999
7. $120,000 or more
8. Prefer not to say

**[marital]** Which of the following best describes your marital status?

1. Single, never married
2. Married
3. Divorced
4. Separated
5. Widowed
6. Living with partner

**[church]** Not counting weddings and funerals, how often do you attend religious services?

1. Never
2. Less than once a year
3. Once a year
4. Several times a year
5. Once a month
6. Two to three times a month
7. Nearly every week
8. Every week
9. More than once per week

**[comments]** Thank you for answering our survey. Do you have any comments for us?

- *TEXTBOX*

**[debriefing]** _(do not show in control condition)_ _Note_: The news article you read was written specifically for the purpose of this study. While the information provided in the article is accurate, it was not originally published in this format. If you have any questions or concerns, please contact the principal investigator Dr. Patrick Kraft (kraftp@uwm.edu).
