const apiBase = "https://blewtx0uid.execute-api.us-east-1.amazonaws.com/dev";

// Fetch products and render as table
function loadProducts() {
    fetch(`${apiBase}/products`)
      .then(res => res.json())
      .then(data => {
        const tableContainer = document.getElementById('products');
        let html = `<table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Price ($)</th>
                            </tr>
                        </thead>
                        <tbody>`;
        data.forEach(p => {
            html += `<tr>
                        <td>${p.id}</td>
                        <td>${p.name}</td>
                        <td>${p.price}</td>
                     </tr>`;
        });
        html += `</tbody></table>`;
        tableContainer.innerHTML = html;
      })
      .catch(err => console.error('Error fetching products:', err));
}

// Submit order
function submitOrder(event) {
    event.preventDefault();

    const order = {
        product_id: document.getElementById('productId').value,
        quantity: parseInt(document.getElementById('quantity').value)
    };

    fetch(`${apiBase}/orders`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(order)
    })
    .then(res => res.json())
    .then(data => {
        if (data.message) {
            alert(data.message);
            document.getElementById('orderForm').reset();
        } else if (data.error) {
            alert("Error: " + data.error);
        }
    })
    .catch(err => alert('Error placing order: ' + err));
}

// Event listeners
document.addEventListener('DOMContentLoaded', loadProducts);
document.getElementById('orderForm').addEventListener('submit', submitOrder);
