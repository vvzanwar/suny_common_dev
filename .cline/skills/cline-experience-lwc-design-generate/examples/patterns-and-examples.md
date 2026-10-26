# experience-lwc-design-generate - Reference Examples, Patterns & Troubleshooting

## Examples

**Phase 1 PRD skeleton (fill from the Figma/PRD/Aura input)**

```text
Component: productCard (<product-card>)
Purpose: Render a compact summary of a product with quick actions.

Content requirements
- Hero image (Product.HeroImage__c)
- Title (Product.Name)
- Subtitle (Product.Tagline__c)
- Primary CTA button ("Add to cart")
- Secondary CTA icon button ("Favorite")

Data requirements
- Input: @api recordId (Product Id)
- Adapter: getRecord (UIAPI) with fields Name, Tagline__c, HeroImage__c
- Events out: addtocart{detail.recordId}, favorite{detail.recordId, detail.value}

States
- Loading (data not yet resolved)
- Error (adapter error)
- Empty (no record found)
- Default

Accessibility
- Title uses <h3>
- Icon-only button carries aria-label="Favorite"
- Card is a labelled region (role="group", aria-labelledby)

Responsiveness
- Full width < 480px
- Side-by-side image + text >= 480px

Styling
- Uses lightning-card wrapper
- Surface color: --slds-g-color-surface-container-1
- Shadow: --slds-g-shadow-1
```

**Phase 2 skeleton**

```javascript
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import NAME from '@salesforce/schema/Product__c.Name';
import TAGLINE from '@salesforce/schema/Product__c.Tagline__c';
import HERO from '@salesforce/schema/Product__c.HeroImage__c';

const FIELDS = [NAME, TAGLINE, HERO];

export default class ProductCard extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record;

    get hasRecord() { return this.record?.data != null; }
    get isLoading() { return !this.record; }
    get hasError()  { return !!this.record?.error; }
    get name()      { return this.record?.data?.fields?.Name?.value ?? ''; }
    get tagline()   { return this.record?.data?.fields?.Tagline__c?.value ?? ''; }
    get heroUrl()   { return this.record?.data?.fields?.HeroImage__c?.value ?? ''; }

    handleAddToCart() {
        this.dispatchEvent(new CustomEvent('addtocart', { detail: { recordId: this.recordId }, bubbles: true, composed: true }));
    }
    handleFavorite(event) {
        this.dispatchEvent(new CustomEvent('favorite', { detail: { recordId: this.recordId, value: event.detail.value }, bubbles: true, composed: true }));
    }
}
```
