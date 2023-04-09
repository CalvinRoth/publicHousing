import Random 

rng = Random.MersenneTwister(1234);

## On fake house which everyone hates to reflect an empty allocation  
function generate_prefs(n,h)
    prefs = zeros(h+1, n)
    for i=1:n 
        prefs[1:h, i] = Random.shuffle(rng, 1:h)
    end 
    prefs[h+1, :] .= h+1 
    return prefs 
end 

function generate_numerical_prefs(n,h) 
    prefs = zeros(h+1, n)
    gaps = 100/h 
    for i=1:h 
        prefs[i, :] .= 100 - (i * gaps)
    end 
    prefs[h+1, :] .= 0 
    return prefs 
end 

function generate_caps(h, m_cap)
    caps = zeros(h+1)
    caps[1:h] = rand(1:m_cap, h) 
    caps[h+1] = Inf 
    return caps 
end 

function optimal_round_house!(prefs, all, house, cap, used)
    n = size(prefs)[2]
    n_changed = 0 
    lottery = []
    for pp=1:n
        h = all[pp]
        my_score = findfirst( prefs[:, pp] .== h )
        upgrade =  findfirst( prefs[:, pp] .== house)
        if my_score > upgrade 
            push!(lottery, pp) 
        end 
    end 
    sort!(lottery)
    while used[house] < cap[house] && length(lottery) > 0 
        lucky = pop!(lottery) 
        old = all[lucky]
        used[old] -= 1
        all[lucky] = house 
        used[house] += 1 
        n_changed += 1 
    end 
    return n_changed 
end 

function lottery_round_house!(prefs, all, house, cap, used)
    n = size(prefs)[2]
    n_changed = 0 
    lottery = []
    for pp=1:n
        h = all[pp]
        my_score = findfirst( prefs[:, pp] .== h )
        upgrade =  findfirst( prefs[:, pp] .== house)
        if my_score > upgrade 
            push!(lottery, pp) 
        end 
    end 
    Random.shuffle!(lottery)
    while used[house] < cap[house] && length(lottery) > 0 
        lucky = pop!(lottery) 
        old = all[lucky]
        used[old] -= 1
        all[lucky] = house 
        used[house] += 1 
        n_changed += 1 
    end 
    return n_changed 
end 

function lottery_round!(prefs, all, cap, used)
    n_changed = 0 
    n_houses = size(prefs)[1]
    for h=1:n_houses
        n_changed += lottery_round_house!(prefs, all, h, cap, used)
    end 
    return n_changed
end 

function lottery!(prefs, all, cap, used)
    n_changed = 1 
    total = 0 

    while n_changed != 0 
        n_changed = lottery_round!(prefs, all, cap, used)
        total += 1
    end 
    return total 
end 


function score(prefs, all)
    total = 0 
    n = size(prefs)[2]
    for i=1:n 
        total +=  findfirst( prefs[:, i] .== all[i]) 
    end  
    return total 
end 

function score_numeric(prefs_num, prefs, all) 
    total = 0 
    n = size(prefs)[2]
    
    for i=1:n 
        place =  findfirst( prefs[:, i] .== all[i]) 
        total += prefs_num[place, i]
    end  
    return total 
end    


all = [4,5,1,2,3]

n = 1000 
houses = 100 
prefs = generate_prefs(n, houses)
prefs_num = generate_numerical_prefs(n, houses)
caps = generate_caps(houses, 30)
all = (houses + 1) * ones(Int32, n)
used = zeros(houses+1)
used[houses+1] = n  

println("Starting Score: ", score(prefs,all)/n, " ", score_numeric(prefs_num, prefs, all)/n)

println(lottery!(prefs, all, caps, used))

println("Ending score:", score(prefs,all)/n, " ", score_numeric(prefs_num, prefs, all)/n)