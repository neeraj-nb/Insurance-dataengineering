from django.contrib import admin
from .models import Customer, Policy, Purchase
from csvexport.actions import csvexport
# Register your models here.

@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ('customer_number', 'first_name', 'last_name', 'email', 'phone', 'is_active')
    search_fields = ('customer_number', 'first_name', 'last_name', 'email', 'phone')
    actions = [csvexport]

@admin.register(Policy)
class PolicyAdmin(admin.ModelAdmin):
    list_display = ('policy_code', 'category', 'is_active')
    search_fields = ('policy_code', 'category')
    actions = [csvexport]

@admin.register(Purchase)
class PurchaseAdmin(admin.ModelAdmin):
    list_display = ('purchase_number', 'customer', 'policy', 'amount', 'status', 'purchase_date')
    search_fields = ('purchase_number', 'customer__customer_number', 'policy__policy_number')
    actions = [csvexport]