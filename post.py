import requests

url = "http://localhost:3000/api/v1/friends"
headers = {
    "Content-Type": "application/json"
}
data = {
    "user_id_1": "ec352d09-00ac-4329-8834-00097a97e7f2",
    "user_id_2": "c2c6c7ac-a008-408e-9e0e-59fc12173aff"
}

response = requests.post(url, headers=headers, json=data)

print("Status code:", response.status_code)
print("Response:", response.text)
