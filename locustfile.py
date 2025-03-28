from locust import HttpUser, task, between


class AppUser(HttpUser):
    wait_time = between(1, 4)

    @task
    def get_image_request(self):
        self.client.get(
            "/api/image/",
            headers=dict(Authorization=f"Token {self.token}"),
        )

    def on_start(self):
        response = self.client.post(
            "/auth/", json=dict(username="YOUR_USER", password="YOUR_PASSWORD")
        )
        if not response.status_code == 200:
            raise ValueError
        data = response.json()
        self.token = data.get("token")