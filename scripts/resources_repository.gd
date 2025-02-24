extends Node

const COMPONENTS = preload("res://scripts/components.tres")
const ELECTRICITY = preload("res://scripts/electricity.tres")
const FOOD = preload("res://scripts/food.tres")
const WATER = preload("res://scripts/water.tres")
const OXYGEN = preload("res://scripts/oxygen.tres")


const resources: Dictionary = {
	COMPONENTS.type: COMPONENTS,
	ELECTRICITY.type: ELECTRICITY,
	FOOD.type: FOOD,
	WATER.type: WATER,
	OXYGEN.type: OXYGEN
}
