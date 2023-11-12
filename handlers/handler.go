package handlers

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
)

func Handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	if event.Body == "" {
		return events.APIGatewayProxyResponse{
			StatusCode: 400,
			Body:       "Body cannot be empty",
		}, nil
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       event.Body,
	}, nil
}
