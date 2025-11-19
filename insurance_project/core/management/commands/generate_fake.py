# core/management/commands/generate_fake.py

from django.core.management.base import BaseCommand
from django.db import transaction
from faker import Faker
import random
import uuid
from decimal import Decimal
from datetime import timedelta

from core.models import Customer, Policy, Purchase

fake = Faker()
Faker.seed(10)
random.seed(10)


# ---------------------------
# CUSTOMER GENERATION
# ---------------------------
def make_customer(i):
    return Customer(
        customer_number=f"CUST-{i:06d}",
        first_name=fake.first_name(),
        last_name=fake.last_name(),
        date_of_birth=fake.date_of_birth(minimum_age=20, maximum_age=80),
        gender=random.choice(["Male", "Female", "Other"]),
        email=fake.safe_email(),
        phone=fake.msisdn()[:15],
        address_line1=fake.street_address(),
        address_line2=fake.secondary_address(),
        city=fake.city(),
        state=fake.state(),
        postal_code=fake.postcode(),
        country="IN",
    )


# ---------------------------
# POLICY (PRODUCT CATALOG)
# ---------------------------
def make_policy(i):
    categories = [c[0] for c in Policy.CATEGORY]

    effective_from = fake.date_between(start_date='-5y', end_date='-1y')
    effective_to = fake.date_between(start_date='today', end_date='+5y')

    return Policy(
        policy_code=f"POL-{i:04d}",
        name=fake.sentence(nb_words=3).replace(".", ""),
        description=fake.text(max_nb_chars=200),
        category=random.choice(categories),
        base_premium=Decimal(random.randrange(20000, 300000)) / Decimal(100),  # ₹200–₹3000
        currency="INR",
        version=f"v{random.randint(1,5)}",
        is_active=True,
        effective_from=effective_from,
        effective_to=effective_to,
    )


# ---------------------------
# PURCHASE (Order)
# ---------------------------
def make_purchase(customer, policy, index):
    status_choices = [s[0] for s in Purchase.STATUS]

    # logical status flow boost
    status = random.choices(
        population=status_choices,
        weights=[10, 20, 50, 5, 10, 5],  # bias for more active/issued
        k=1
    )[0]

    amount = policy.base_premium + Decimal(random.randrange(-1000, 2000)) / Decimal(100)
    amount = max(amount, Decimal("100.00"))

    purchase_date = fake.date_time_between(start_date="-3y", end_date="now")

    invoice = f"INV-{index:07d}" if random.random() > 0.2 else None

    return Purchase(
        purchase_number=f"PUR-{index:07d}",
        customer=customer,
        policy=policy,
        purchase_date=purchase_date,
        amount=amount,
        currency="INR",
        payment_reference=str(uuid.uuid4()),
        status=status,
        invoice_number=invoice,
    )


# ---------------------------
# COMMAND
# ---------------------------
class Command(BaseCommand):
    help = "Generate synthetic Customer, Policy, and Purchase data"

    def add_arguments(self, parser):
        parser.add_argument('--customers', type=int, default=50)
        parser.add_argument('--policies', type=int, default=20)
        parser.add_argument('--purchases-per-customer', type=int, default=2)
        parser.add_argument('--commit', action='store_true')

    def handle(self, *args, **opts):
        num_customers = opts['customers']
        num_policies = opts['policies']
        ppc = opts['purchases_per_customer']
        commit = opts['commit']

        created = {"customers": 0, "policies": 0, "purchases": 0}

        with transaction.atomic():
            # ----- POLICIES -----
            policies = []
            for i in range(1, num_policies + 1):
                pol = make_policy(i)
                if commit:
                    pol.save()
                policies.append(pol)
                created["policies"] += 1

            # ----- CUSTOMERS + PURCHASES -----
            purchase_counter = 1
            for i in range(1, num_customers + 1):
                cust = make_customer(i)
                if commit:
                    cust.save()
                created["customers"] += 1

                for _ in range(ppc):
                    policy = random.choice(policies)
                    pur = make_purchase(cust, policy, purchase_counter)
                    if commit:
                        pur.save()
                    created["purchases"] += 1
                    purchase_counter += 1

            if commit:
                self.stdout.write(self.style.SUCCESS(f"Data created: {created}"))
            else:
                self.stdout.write(self.style.WARNING(f"Dry-run. Would create: {created}"))
