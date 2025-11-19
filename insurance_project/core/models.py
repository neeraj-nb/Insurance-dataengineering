# core/models.py
import uuid
from decimal import Decimal

from django.db import models
from django.utils import timezone
from django.core.validators import MinValueValidator



class Customer(models.Model):
    """
    Individual-only customer model. Address fields are embedded here per your requirement.
    """
    # PK
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # business key
    customer_number = models.CharField(max_length=40, unique=True)

    # personal attributes
    first_name = models.CharField(max_length=120)
    last_name = models.CharField(max_length=120)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=10, null=True, blank=True)

    # contact
    email = models.EmailField(max_length=254, null=True, blank=True)
    phone = models.CharField(max_length=30, null=True, blank=True)

    # address fields (embedded)
    address_line1 = models.CharField(max_length=255, null=True, blank=True)
    address_line2 = models.CharField(max_length=255, null=True, blank=True)
    city = models.CharField(max_length=120, null=True, blank=True)
    state = models.CharField(max_length=120, null=True, blank=True)
    postal_code = models.CharField(max_length=20, null=True, blank=True)
    country = models.CharField(max_length=80, default='IN')

    # metadata
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now, editable=False)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "customer"
        indexes = [
            models.Index(fields=['customer_number']),
            models.Index(fields=['last_name', 'first_name']),
        ]

    def __str__(self):
        return f"{self.customer_number} - {self.first_name} {self.last_name}"


class Policy(models.Model):
    """
    Represents the catalogue of products offered by the company.
    (Was previously 'policy' as a contractual header; now acts as available product.)
    """
    CATEGORY = [
        ('personal_auto', 'Personal Auto'),
        ('homeowners', 'Homeowners'),
        ('term_life', 'Term Life'),
        ('health', 'Health'),
        ('other', 'Other'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    # business/product code + human name
    policy_code = models.CharField(max_length=60, unique=True)
    name = models.CharField(max_length=180)
    description = models.TextField(null=True, blank=True)
    category = models.CharField(max_length=40, choices=CATEGORY, default='other')

    # product-level pricing default (can be overridden per Purchase/order)
    base_premium = models.DecimalField(
        max_digits=12, decimal_places=2, validators=[MinValueValidator(Decimal('0.00'))], default=Decimal('0.00')
    )
    currency = models.CharField(max_length=10, default='INR')

    # product lifecycle
    is_active = models.BooleanField(default=True)
    version = models.CharField(max_length=10,null=False, blank=False)
    effective_from = models.DateField(null=True, blank=True)
    effective_to = models.DateField(null=True, blank=True)

    created_at = models.DateTimeField(default=timezone.now, editable=False)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "policy_catalog"
        indexes = [
            models.Index(fields=['policy_code']),
            models.Index(fields=['category']),
            models.Index(fields=['is_active']),
        ]

    def __str__(self):
        return f"{self.policy_code} - {self.name}"


class Purchase(models.Model):
    """
    Transactional link between Customer and Policy (product).
    Purchase represents an order/transaction that attaches a customer to a product.
    policy FK is required (non-null) to reflect that a purchase always references a product.
    """
    STATUS = [
        ('quoted', 'quoted'),
        ('issued', 'issued'),
        ('active', 'active'),
        ('cancelled', 'Refunded'),
        ('lapsed', 'Lapsed'),
        ('expired', 'Expired'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    purchase_number = models.CharField(max_length=60, unique=True)

    # mandatory references
    customer = models.ForeignKey(Customer, on_delete=models.PROTECT, related_name='purchases')
    policy = models.ForeignKey(Policy, on_delete=models.PROTECT, related_name='purchases')  # required link to product

    # transactional data
    purchase_date = models.DateTimeField(default=timezone.now)
    # expiry date to be generated in ETL pipeline
    # amount is the agreed charge for this purchase; defaults to product base_premium but stored here for immutability
    # underwriting_decision = models.TextField()
    amount = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(Decimal('0.00'))])
    currency = models.CharField(max_length=10, default='INR')
    payment_reference = models.CharField(max_length=255, null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS, default='pending')
    invoice_number = models.CharField(max_length=80, null=True, blank=True)

    created_at = models.DateTimeField(default=timezone.now, editable=False)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "purchase"
        indexes = [
            models.Index(fields=['purchase_number']),
            models.Index(fields=['customer']),
            models.Index(fields=['policy']),
            models.Index(fields=['purchase_date']),
        ]

    def __str__(self):
        return f"{self.purchase_number} - {self.customer.customer_number} -> {self.policy.policy_code} - {self.amount}"