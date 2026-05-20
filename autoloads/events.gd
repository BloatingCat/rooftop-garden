extends Node

signal customer_arrived(customer: Dictionary)
signal customer_served(customer: Dictionary)
signal customer_left(customer: Dictionary)
signal aura_gained(amount: int, source: String)
signal food_made()
signal day_ended(day: int, aura_this_day: int)
signal day_started(day: int)
signal serving_started(customer: Dictionary)
