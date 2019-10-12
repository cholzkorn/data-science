# Python Object-Oriented Programming

class Employee:

    raise_amount = 1.04

    def __init__(self, first, last, pay): # dunder functions are implicitly called
        self.first = first
        self.last = last
        self.pay = pay
        self.email = first + '.' + last + '@company.com'

    def fullname(self):
        return '{} {}'.format(self.first, self.last)

    def apply_raise(self):
        self.pay = int(self.pay * self.raise_amount)

    def __repr__(self): # debugging dunder - reproduce
        return "Employee('{}', '{}', '{}')".format(self.first, self.last, self.pay)

    def __str__(self): # readable for enduser
        return '{} - {}'.format(self.fullname(), self.email)

    def __add__(self, other):
        return self.pay + other.pay

    def __len__(self):
        return len(self.fullname())



emp_1 = Employee('Corey', 'Schafer', 50000)
emp_2 = Employee('Test', 'User', 60000)

print('Most important dunder functions:')
print(emp_1) # implicitly calls __str__
print(repr(emp_1))
print(str(emp_1))

print('Other functions:')
print(emp_1 + emp_2)
print(len(emp_1))
