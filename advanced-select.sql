-- Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table:
-- Equilateral: It's a triangle with 3 sides of equal length.
-- Isosceles: It's a triangle with 2 sides of equal length.
-- Scalene: It's a triangle with 3 sides of differing lengths.
-- Not A Triangle: The given values of A, B, and C don't form a triangle.

select
    case
        when a + b <= c or a + c <= b or b + c <= a then 'Not A Triangle'
        when a = b and b = c then 'Equilateral'
        when a = b or a = c or b = c then 'Isosceles'
        else 'Scalene'
    end 
from triangles;

-- Generate the following two result sets:
-- 1. Query an alphabetically ordered list of all names in OCCUPATIONS, immediately followed by the first letter of each profession as a parenthetical (i.e.: enclosed in parentheses). For example: AnActorName(A), ADoctorName(D), AProfessorName(P), and ASingerName(S).
-- 2. Query the number of ocurrences of each occupation in OCCUPATIONS. Sort the occurrences in ascending order, and output them in the following format:
-- `There are a total of [occupation_count] [occupation]s.`
-- where [occupation_count] is the number of occurrences of an occupation in OCCUPATIONS and [occupation] is the lowercase occupation name. If more than one Occupation has the same [occupation_count], they should be ordered alphabetically.
-- Note: There will be at least two entries in the table for each type of occupation.

select concat(name, '(', substr(occupation, 1, 1), ')') from occupations order by name;
select concat('There are a total of ', count(*), ' ', lower(occupation), 's.') from occupations
group by occupation order by count(*), occupation;

-- Pivot the Occupation column in OCCUPATIONS so that each Name is sorted alphabetically and displayed underneath its corresponding Occupation. The output should consist of four columns (Doctor, Professor, Singer, and Actor) in that specific order, with their respective names listed alphabetically under each column.
-- Note: Print NULL when there are no more names corresponding to an occupation.

select
    max(case when occupation = 'Doctor' then name end) as Doctor,
    max(case when occupation = 'Professor' then name end) as Professor,
    max(case when occupation = 'Singer' then name end) as Singer,
    max(case when occupation = 'Actor' then name end) as Actor
from (
    select name, occupation, 
        row_number() over ( partition by occupation order by name) as rn
    from occupations
) t
group by rn
order by rn;

-- Given the table schemas below, write a query to print the company_code, founder name, total number of lead managers, total number of senior managers, total number of managers, and total number of employees. Order your output by ascending company_code.
-- Note:
-- The tables may contain duplicate records.
-- The company_code is string, so the sorting should not be numeric. For example, if the company_codes are C_1, C_2, and C_10, then the ascending company_codes will be C_1, C_10, and C_2.

select 
    c.company_code, c.founder, count(distinct lm.lead_manager_code), count(distinct sm.senior_manager_code), count(distinct m.manager_code), count(distinct e.employee_code) 
from Company c
left join Lead_Manager lm on c.company_code = lm.company_code
left join Senior_Manager sm on c.company_code = sm.company_code
left join Manager m on c.company_code = m.company_code
left join Employee e on c.company_code = e.company_code
group by c.company_code, c.founder
order by c.company_code;

-- Julia asked her students to create some coding challenges. Write a query to print the hacker_id, name, and the total number of challenges created by each student. Sort your results by the total number of challenges in descending order. If more than one student created the same number of challenges, then sort the result by hacker_id. If more than one student created the same number of challenges and the count is less than the maximum number of challenges created, then exclude those students from the result.

select h.hacker_id, h.name, count(c.challenge_id) as challenge_created from Hackers h
join Challenges c on h.hacker_id = c.hacker_id
group by h.hacker_id, h.name
having (
    count(c.challenge_id) = (
        select max(challenge_count)
        from (
            select count(*) as challenge_count
            from Challenges
            group by hacker_id
        ) t
    )
    or count(c.challenge_id) in (
        select challenge_count
        from (
            select hacker_id, count(*) as challenge_count
            from Challenges
            group by hacker_id
        ) t
        group by challenge_count
        having count(*) = 1
    )
)
order by count(c.challenge_id) desc, h.hacker_id;