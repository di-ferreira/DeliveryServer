describe('Rotas caixa', () => {
    let id:number;

    it('Criar caixa - 01', () => {
        cy.request({
            method: 'POST',
            url: '/caixas',
            body: {
                "id": 0,
                "total": 0.00,
                "aberto": true
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('caixa aberto com sucesso!');
            expect(Response.body[1].total).to.equal(0.00);
            expect(Response.body[1].data).to.equal(Date.now());
            id = Response.body[1].id;
        });
    });

    it('Buscar caixas', () => {
        cy.request('/caixas')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.count).to.equal(1);
            });
    });

    it('Buscar caixa por ID', () => {
        cy.request(`/caixas/${id}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id);
        });
    });

    it('Update caixa', () => {
        cy.request({
            method: 'PUT',
            url: `/caixas/${id}`,
            body: {
                "id": id,
                "aberto": false
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id);
            expect(Response.body.aberto).to.equal(false);
        });
    });

    after(() => {
        cy.request({
            method: 'DELETE',
            url: '/clientes/55229785634',
            failOnStatusCode: false
        });
    });

});