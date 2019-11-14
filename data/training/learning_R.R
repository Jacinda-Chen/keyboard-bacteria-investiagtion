# A script to learn about R

# Jacinda Chen
# November 6, 2019
# jrchen@dons.usfca.edu

# variable assignment
my_variable_3 <- 3
my_variable_2 <- 2
my_variable_1 <- 1

# using variable in math
my_variable_1 * my_variable_2 * my_variable_3

# printing out when sourcing
print(my_variable_1 * my_variable_2 * my_variable_3)

# making a vector in R
my_vector <- c(1, 2, 3, 4, 8, 10, 12)

# the fifth element in the vector
my_vector[5]

# the third through seventh elements of the vector
my_vector[3:7]

# let's store the subset to a new variable
subset_of_vector <- my_vector[3:7]

# let's try to make a mixed vector
mixed_vector <- c("apple", 3, "two")

# matrices sare 2 dimensions and have one type
matrix(data = 1:9, nrow = 3, ncol = 3)

# matrices that won't give you error messages
matrix(data = 1:3, nrow = 3, ncol = 3)
matrix(data = 1:2, nrow = 3, ncol = 3)

# PCR plate, could format data in this way
matrix(data = NA, nrow = 8, ncol = 12)

# lists are 1 dimensional but can have many types
my_list <- list("apple", 2, "three")

# indexing into lists is a little different
my_list[1] # returns a list of length

# Get just apple back
my_list[[1]] # returns just the thing itself with double syntax

# more complex example of a list
list(1:9, 3, "banana")

# an example data frame that is already built into R-Studio
iris

iris$Species

typeof(iris$Species)
as.numeric(iris$Species)

typeof(mixed_vector)

# factors are categorical variables that are stored as integers behind the
# scences